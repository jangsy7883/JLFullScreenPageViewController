//
//  KMPagerController.m
//  JLFullScreenPageViewController
//
//  Created by Jangsy7883 on 2015. 9. 4..
//  Copyright © 2015년 Dalkomm. All rights reserved.
//

#import "JLFullScreenPageViewController.h"
#import "UIViewController+JLFSAdditions.h"

CG_INLINE CGRect
CGRectReplaceY(CGRect rect, CGFloat y)
{
    rect.origin.y = y;
    return rect;
}

@implementation UIViewController (KMPageViewController)

- (JLFullScreenPageViewController*)fullScreenPageViewController
{
    for (UIView* next = self.view; next; next = next.superview)
    {
        UIResponder* nextResponder = [next nextResponder];
        
        if ([nextResponder isKindOfClass:[JLFullScreenPageViewController class]])
        {
            return (JLFullScreenPageViewController*)nextResponder;
        }
    }
    return nil;
}

@end

static void * const KMPageViewControllerKVOContext = (void*)&KMPageViewControllerKVOContext;

@interface JLFullScreenPageViewController ()

@property (nonatomic, assign) BOOL animating;
@property (nonatomic, assign) BOOL tracking;
@property (nonatomic, assign) CGFloat trackingBeginPoint;

@property (nonatomic, strong) UINavigationBar *navigationBar;
@property (nonatomic, strong) UIView *contentHeaderView;
@property (nonatomic, strong) JLPageViewController *pageViewController;

@property (nonatomic, readonly, getter=isTabBarHidden) BOOL tabBarHidden;
@end

@implementation JLFullScreenPageViewController

#pragma mark - memory

- (void)dealloc
{
    //Observer
    [self.contentHeaderView removeObserver:self
                                forKeyPath:NSStringFromSelector(@selector(frame))
                                   context:KMPageViewControllerKVOContext];
}

#pragma mark - view lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _fullScreenStyle = JLFullScreenStyleScrolling;
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    //PAGEVIEW
    self.pageViewController = [[JLPageViewController alloc] init];
    self.pageViewController.dataSource = self;
    self.pageViewController.delegate = self;
    [self addChildViewController:self.pageViewController];
    [self.view addSubview:self.pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
    
    //CONTENT HEDAER VIEW
    self.contentHeaderView = [[UIView alloc] init];
    [self.contentHeaderView addObserver:self
                             forKeyPath:NSStringFromSelector(@selector(frame))
                                options:NSKeyValueObservingOptionNew
                                context:KMPageViewControllerKVOContext];
    [self.view addSubview:self.contentHeaderView];
    
    //NAVIGATIONBAR
    self.navigationBar = [[UINavigationBar alloc] init];
    self.navigationBar.items = @[[UINavigationItem new]];
    [self.contentHeaderView addSubview:self.navigationBar];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    self.pageViewController.view.frame = self.view.bounds;
    
    [self layoutContentHeaderView];
    [self layoutNavigationBarItemsAlphaValue];
    
    if (self.tabBarController && self.tabBarHidden)
    {
        CGRect tabBarRect = self.tabBarController.tabBar.frame;
        tabBarRect.origin.y = CGRectGetHeight(self.tabBarController.view.bounds);
        self.tabBarController.tabBar.frame = tabBarRect;
    }
}

#pragma  mark - layout

- (void)layoutContentHeaderView
{
    CGRect bounds = self.view.bounds;
    
    CGRect rect = CGRectMake(0,
                             0,
                             CGRectGetWidth(bounds),
                             (!self.navigationBarHidden ? CGRectGetHeight(self.navigationController.navigationBar.frame) : 0) + self.topLayoutGuide.length);
    
    if (self.navigationBarHidden == NO)
    {
        self.navigationBar.frame = rect;
        [self.navigationBar setNeedsLayout];
        [self.navigationBar layoutIfNeeded];
    }
    
    self.headerView.frame = CGRectMake(0,
                                       CGRectGetMaxY(rect),
                                       CGRectGetWidth(bounds),
                                       CGRectGetHeight(self.headerView.frame));
    
    self.contentHeaderView.frame = CGRectMake(0,
                                              CGRectGetMinY(self.contentHeaderView.frame),
                                              CGRectGetWidth(bounds),
                                              CGRectGetHeight(rect) + CGRectGetHeight(self.headerView.frame));
}

- (void)layoutContentInsetForScrollView:(UIScrollView*)scrollView atContentInsetTop:(CGFloat)insetTop
{
    if ([scrollView isKindOfClass:[UIScrollView class]])
    {
        UIEdgeInsets contentInset = scrollView.contentInset;
        contentInset.top = insetTop;
        scrollView.contentInset = contentInset;
        
        scrollView.scrollIndicatorInsets = contentInset;
    }
}

- (void)layoutContentInsetAllChildScrollViews
{
    CGFloat maxY = CGRectGetMaxY(self.contentHeaderView.frame);
    
    for (UIViewController *viewController in self.pageViewController.viewControllers)
    {
        [self layoutContentInsetForScrollView:viewController.jl_scrollView
                            atContentInsetTop:maxY];
    }
}

- (void)layoutNavigationBarItemsAlphaValue
{
    CGFloat minimumLocation = self.topLayoutGuide.length - CGRectGetHeight(self.navigationBar.frame);
    CGFloat alpha = -(CGRectGetMinY(self.contentHeaderView.frame) - minimumLocation) / minimumLocation;
    
    for (UIView *view in self.navigationBar.subviews)
    {
        bool isBackgroundView = (view == self.navigationBar.subviews.firstObject);
        bool isViewHidden = view.hidden || view.alpha < FLT_EPSILON;
        
        if (!isBackgroundView && !isViewHidden)
        {
            view.alpha = MAX(alpha, FLT_EPSILON);
        }
    }
}

#pragma mark - scrollview

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView
{
    _tracking = NO;
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        if (CGRectGetMinY(self.contentHeaderView.frame) != -CGRectGetHeight(self.navigationController.navigationBar.frame) && CGRectGetMinY(self.contentHeaderView.frame) != 0)
        {
            [self setFullScreen:CGRectGetMinY(self.contentHeaderView.frame) < -22
                       animated:YES
                     completion:nil];
        }
    });
}

- (void)scrollView:(UIScrollView*)scrollView didScrollToContentOffset:(CGPoint)toContentOffset fromContentOffset:(CGPoint)formContentOffset
{
    if (toContentOffset.y+scrollView.frame.size.height < scrollView.contentSize.height)
    {
        if (_fullScreenStyle == JLFullScreenStyleAutomatic)
        {
            if (scrollView.tracking)
            {
                if (_animating == NO)
                {
                    if (_tracking == NO)
                    {
                        _tracking = YES;
                        _trackingBeginPoint = scrollView.contentOffset.y;
                    }
                    else
                    {
                        if (_trackingBeginPoint - scrollView.contentOffset.y < -20)
                        {
                            [self setFullScreen:YES animated:YES completion:^{
                                _tracking = NO;
                            }];
                        }
                        else if (_trackingBeginPoint - scrollView.contentOffset.y > 20)
                        {
                            [self setFullScreen:NO animated:YES completion:^{
                                _tracking = NO;
                            }];
                        }
                    }
                }
            }
        }
        else if (_fullScreenStyle == JLFullScreenStyleScrolling)
        {
            if (scrollView.tracking)
            {
                CGRect headerRect = self.contentHeaderView.frame;
                CGRect tabBarRect = self.tabBarController.tabBar.frame;
                CGRect tabBarControllerRect = self.tabBarController.view.frame;
                
                if (toContentOffset.y > -CGRectGetHeight(headerRect))
                {
                    CGFloat minY = CGRectGetHeight(self.navigationBar.frame) - (self.navigationBar? self.topLayoutGuide.length : 0);
                    CGFloat y = CGRectGetMinY(headerRect) - (toContentOffset.y - formContentOffset.y);
                    
                    headerRect = CGRectReplaceY(headerRect, ceil(MAX(-minY, MIN(0,y))));
                    
                    
                    minY = CGRectGetHeight(tabBarControllerRect) - CGRectGetHeight(tabBarRect);
                    y = CGRectGetMinY(tabBarRect) + (toContentOffset.y - formContentOffset.y);
                    
                    tabBarRect = CGRectReplaceY(tabBarRect,MAX(minY, MIN(y, CGRectGetMaxY(tabBarControllerRect))));
                }
                else
                {
                    headerRect = CGRectReplaceY(headerRect, 0);
                    tabBarRect = CGRectReplaceY(tabBarRect, CGRectGetHeight(tabBarControllerRect) - CGRectGetHeight(tabBarRect));
                }
                
                // SET HEDAER FRAME
                if (CGRectEqualToRect(headerRect, self.contentHeaderView.frame) == NO)
                {
                    self.contentHeaderView.frame = headerRect;
                }
                
                // SET TABBAR FRAME
                if (self.tabBarController && CGRectEqualToRect(tabBarRect, self.tabBarController.tabBar.frame) == NO)
                {
                    self.tabBarController.tabBar.frame = tabBarRect;
                    
                    BOOL isHidden = CGRectGetMinY(tabBarRect) == CGRectGetHeight(tabBarControllerRect);
                    
                    if (self.tabBarHidden != isHidden)
                    {
                        self.tabBarHidden = isHidden;
                    }
                }
            }
        }
    }
}

#pragma  mark - Observers

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == KMPageViewControllerKVOContext)
    {
        if([keyPath isEqualToString:@"frame"] && [object isKindOfClass:[self.contentHeaderView class]])
        {
            [self layoutContentInsetAllChildScrollViews];
            [self layoutNavigationBarItemsAlphaValue];
        }
    }
    else
    {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - navigation bar

- (void)setFullScreen:(BOOL)isFullScreen animated:(BOOL)animated completion:(void (^)(void))completion
{
    if (self.navigationBarHidden == NO)
    {
        CGRect navigationBarRect = CGRectZero;
        CGRect tabBarRect = self.tabBarController.tabBar.frame;
        
        if (isFullScreen)
        {
            tabBarRect.origin.y = CGRectGetHeight(self.tabBarController.view.bounds);
            navigationBarRect = CGRectMake(0,
                                           -(self.navigationBar.frame.size.height - self.topLayoutGuide.length),
                                           CGRectGetWidth(self.view.bounds),
                                           CGRectGetHeight(self.contentHeaderView.frame));
        }
        else
        {
            tabBarRect.origin.y = CGRectGetMaxY(self.tabBarController.view.bounds) - CGRectGetHeight(self.tabBarController.tabBar.frame);
            navigationBarRect = CGRectMake(0,
                                           0,
                                           CGRectGetWidth(self.view.bounds),
                                           CGRectGetHeight(self.contentHeaderView.frame));
        }
        
        if (CGRectEqualToRect(self.contentHeaderView.frame, navigationBarRect) == NO && _animating == NO)
        {
            _animating = YES;
            
            if (animated)
            {
                [UIView animateWithDuration:0.25
                                      delay:0
                     usingSpringWithDamping:1
                      initialSpringVelocity:15
                                    options:UIViewAnimationOptionCurveEaseInOut
                                 animations:^{
                                     self.contentHeaderView.frame = navigationBarRect;
                                     self.tabBarController.tabBar.frame = tabBarRect;
                                 }
                                 completion:^(BOOL finished) {
                                     if (finished)
                                     {
                                         _animating = NO;
                                         
                                         if (completion)
                                         {
                                             completion();
                                         }
                                     }
                                 }];
            }
            else
            {
                self.contentHeaderView.frame = navigationBarRect;
                self.tabBarController.tabBar.frame = tabBarRect;
                
                _animating = NO;
                
                if (completion)
                {
                    completion();
                }
            }
        }
    }
}


#pragma mark - KMPagerView datasource

- (NSArray *)viewControllersForPageViewController:(JLPageViewController *)pageView
{
    return nil;
}

#pragma mark - KMPagerView delegate

- (void)pageViewController:(JLPageViewController*)pageView didScrollToCurrentOffset:(CGPoint)contentOffset
{
    
}

- (void)pageViewController:(JLPageViewController*)pageView didScrollToCurrentIndex:(NSUInteger)currentIndex
{
    
}

#pragma mark - SETTERS

- (void)setNavigationBarHidden:(BOOL)navigationBarHidden
{
    if (_navigationBarHidden != navigationBarHidden)
    {
        _navigationBarHidden = navigationBarHidden;
        
        [self layoutContentHeaderView];
    }
}

- (void)setHeaderView:(UIView *)headerView
{
    if (_headerView != headerView)
    {
        [_headerView removeFromSuperview];
        
        _headerView = nil;
        _headerView = headerView;
        
        [self.contentHeaderView addSubview:_headerView];
        
        [self layoutContentHeaderView];
    }
}

- (void)setTabBarHidden:(BOOL)isHidden
{
    for (UIView *subview in self.tabBarController.tabBar.subviews)
    {
        subview.hidden = isHidden;
    }
}

#pragma mark - GETTERS

- (BOOL)isTabBarHidden
{
    UIView *view = self.tabBarController.tabBar.subviews.firstObject;
    
    return view.hidden;
}

@end
