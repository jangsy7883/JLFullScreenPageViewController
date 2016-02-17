//
//  KMPagerController.m
//  KMPageController
//
//  Created by IM049 on 2015. 9. 4..
//  Copyright (c) 2015년 Jangsy7883. All rights reserved.
//

#import "KMPageViewController.h"


CG_INLINE CGRect
CGRectReplaceY(CGRect rect, CGFloat y)
{
    rect.origin.y = y;
    return rect;
}

#define kDefaultNavigationBarHeight 44

static void * const KMScrollViewKVOContext = (void*)&KMScrollViewKVOContext;
@interface KMPageViewController ()

@property (nonatomic, strong) UIView *contentHeaderView;
@property (nonatomic, strong) KMPageView *pageView;
@property (nonatomic, strong) NSTimer *didScrollTimer;
@end

@implementation KMPageViewController

#pragma mark - view lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.pageView = [[KMPageView alloc] init];
    [self.view addSubview:self.pageView];

    self.contentHeaderView = [[UIView alloc] init];
    [self.view addSubview:self.contentHeaderView];
    
    [self.contentHeaderView addObserver:self
                 forKeyPath:@"frame"
                    options:NSKeyValueObservingOptionNew
                    context:KMScrollViewKVOContext];

}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    self.pageView.frame = self.view.bounds;

    [self layoutContentHeaderView];
}

- (void)onDidScrollTimer:(NSTimer*)timer
{
    [self.didScrollTimer invalidate];
    self.didScrollTimer = nil;
    
    [self navigationBarIsVisible:CGRectGetMinY(self.contentHeaderView.frame) > -22
                        animated:YES];
}

- (void)didScrollTimerIsActive:(BOOL)isActive
{
    if (self.didScrollTimer)
    {
        [self.didScrollTimer invalidate];
        self.didScrollTimer = nil;
    }
    
    if (isActive)
    {
        self.didScrollTimer = [NSTimer scheduledTimerWithTimeInterval:1
                                                               target:self
                                                             selector:@selector(onDidScrollTimer:)
                                                             userInfo:nil
                                                              repeats:NO];
    }
}

#pragma  mark -

- (void)layoutContentHeaderView
{
    CGRect bounds = self.view.bounds;
    
    CGFloat defaultBarHeight = (self.navigationController.navigationBar) ? CGRectGetHeight(self.navigationController.navigationBar.frame): kDefaultNavigationBarHeight;
    
    self.navigationBar.frame = CGRectMake(0,
                                          0,
                                          CGRectGetWidth(bounds),
                                          defaultBarHeight+self.topLayoutGuide.length);
    
    self.headerView.frame = CGRectMake(0,
                                       CGRectGetMaxY(self.navigationBar.frame),
                                       CGRectGetWidth(bounds),
                                       CGRectGetHeight(self.headerView.frame));

    self.contentHeaderView.frame = CGRectMake(0,
                                              0,
                                              CGRectGetWidth(bounds),
                                              CGRectGetHeight(self.navigationBar.frame) + CGRectGetHeight(self.headerView.frame));

    [self layoutContentInsetAllChildScrollViews];
}

- (void)layoutContentInsetForScrollView:(UIScrollView*)scrollView atContentOffsetY:(CGFloat)offsetY
{
    if ([scrollView isKindOfClass:[UIScrollView class]])
    {
        UIEdgeInsets inset = scrollView.contentInset;
        inset.top = offsetY;
        
        if (!UIEdgeInsetsEqualToEdgeInsets(scrollView.contentInset, inset))
        {
            BOOL isZero = (scrollView.contentInset.top == 0);

            scrollView.contentInset = inset;
            scrollView.scrollIndicatorInsets = inset;
            
            if (isZero)
            {
                [scrollView setContentOffset:CGPointMake(0, -scrollView.contentInset.top) animated:NO];
            }
        }
    }
}

- (void)layoutContentInsetAllChildScrollViews
{
    CGFloat pageY = CGRectGetMaxY(self.contentHeaderView.frame);

    for (UITableViewController *tableViewController in self.childViewControllers)
    {
        [self layoutContentInsetForScrollView:(id)tableViewController.view
                             atContentOffsetY:pageY];
    }
}

#pragma  mark -

- (void)addChildScrollView:(UIScrollView *)scrollView
{
    if ([scrollView isKindOfClass:[UIScrollView class]])
    {
        [self removeChildScrollView:scrollView];

        //Observer
        [scrollView addObserver:self
               forKeyPath:@"contentOffset"
                  options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew
                  context:KMScrollViewKVOContext];
    }
}

- (void)removeChildScrollView:(UIScrollView *)scrollView
{
    if ([scrollView isKindOfClass:[UIScrollView class]])
    {
        //Observer
        @try {
            [scrollView removeObserver:self
                            forKeyPath:@"contentOffset"
                               context:KMScrollViewKVOContext];
        }
        @catch (NSException *exception) {}
    }
}

#pragma  mark -

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == KMScrollViewKVOContext)
    {
        if ([keyPath isEqualToString:@"contentOffset"])
        {
            UIScrollView *scrollView = object;
            CGPoint new = [[change objectForKey:NSKeyValueChangeNewKey] CGPointValue];
            CGPoint old = [[change objectForKey:NSKeyValueChangeOldKey] CGPointValue];
            
            if (scrollView.frame.origin.x == self.pageView.contentOffset.x &&
                new.y != old.y &&
                scrollView.contentOffset.y > -CGRectGetHeight(self.contentHeaderView.frame) &&
                scrollView.contentOffset.y+scrollView.frame.size.height < scrollView.contentSize.height)
            {
                CGFloat y = CGRectGetMinY(self.contentHeaderView.frame)-(new.y - old.y);
                CGRect rect = CGRectReplaceY(self.contentHeaderView.frame,
                                             MAX(-44, MIN(0,y)));
                
                if (CGRectEqualToRect(rect, self.contentHeaderView.frame) == NO)
                {
                    self.contentHeaderView.frame = rect;
                }
                [self didScrollTimerIsActive:YES];
            }
            
        }
        else if([keyPath isEqualToString:@"frame"])
        {
            [self layoutContentInsetAllChildScrollViews];
        }
    }
    else
    {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark

- (void)navigationBarIsVisible:(BOOL)isVisible animated:(BOOL)animated
{
    CGRect beginRect = CGRectZero;
    CGRect endRect = CGRectZero;
    CGRect baseRect = CGRectMake(0,
                                 0,
                                 CGRectGetWidth(self.view.bounds),
                                 CGRectGetHeight(self.contentHeaderView.frame));
    
    if (isVisible)
    {
        beginRect = CGRectOffset(baseRect, 0, -20); //HIDE
        endRect = CGRectOffset(baseRect, 0, 0); //SHOW
    }
    else
    {
        beginRect = CGRectOffset(baseRect, 0, 0); //SHOW
        endRect = CGRectOffset(baseRect, 0, -(self.navigationBar.frame.size.height - self.topLayoutGuide.length)); //HIDE
    }
    
    if (CGRectEqualToRect(self.contentHeaderView.frame, endRect) == NO)
    {
        if (animated)
        {
            [UIView animateWithDuration:0.25
                                  delay:0
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 self.contentHeaderView.frame = endRect;
                             }
                             completion:^(BOOL finished) {
                             }];
        }
        else
        {
            self.contentHeaderView.frame = endRect;
        }
    }
}

#pragma mark - SETTERS

- (void)setHeaderView:(UIView *)headerView
{
    if (_headerView != headerView)
    {
        [_headerView removeFromSuperview];

        _headerView = nil;
        _headerView = headerView;

        [self.contentHeaderView addSubview:_headerView];
    }
}

- (void)setNavigationBar:(UINavigationBar *)navigationBar
{
    if (_navigationBar != navigationBar)
    {
        [_navigationBar removeFromSuperview];
        
        _navigationBar = nil;
        _navigationBar = navigationBar;
        
        [self.contentHeaderView addSubview:_navigationBar];
    }
}

#pragma mark - GETTERS

- (KMPageView*)pageView
{
    if (_pageView == nil)
    {
    }
    return _pageView;
}

@end

@implementation UIViewController (KMPageViewController)

- (KMPageViewController*)pageViewController
{
    for (UIView* next = self.view; next; next = next.superview)
    {
        UIResponder* nextResponder = [next nextResponder];
        
        if ([nextResponder isKindOfClass:[KMPageViewController class]])
        {
            return (KMPageViewController*)nextResponder;
        }
    }
    return nil;
}

@end