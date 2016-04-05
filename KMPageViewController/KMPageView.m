//
//  KMPagerView.m
//  KMSegmentedPager
//
//  Created by Jangsy7883 on 2015. 9. 4..
//  Copyright © 2015년 Dalkomm. All rights reserved.
//

#import "KMPageView.h"
#import "KMPageViewController.h"
#import "UIViewController+KMAdditions.h"

@interface KMPageViewController ()

@property (nonatomic, readonly) UIView *contentHeaderView;

- (void)layoutContentInsetForScrollView:(UIScrollView*)scrollView atContentOffsetY:(CGFloat)offsetY;

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView;
- (void)scrollView:(UIScrollView*)scrollView didScrollToContentOffset:(CGPoint)toContentOffset fromContentOffset:(CGPoint)formContentOffset;

@end

@interface KMPageView () <UIPageViewControllerDataSource, UIPageViewControllerDelegate,UIScrollViewDelegate>
{
    BOOL changingOrientationState;
}

@property (nonatomic, strong) UIPageViewController *contentViewController;

@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, weak) KMPageViewController *pageViewController;

@property (nonatomic, strong) NSArray *viewControllers;

@end

@implementation KMPageView

static void * const KMPagerViewKVOContext = (void*)&KMPagerViewKVOContext;

#pragma mark - memory

- (void)dealloc
{
    for (UIViewController *viewController in self.viewControllers)
    {
        UIScrollView *scrollView = viewController.contentScrollView;
        
        if ([scrollView isKindOfClass:[UIScrollView class]])
        {
            [self removeObserverForObject:scrollView forKeyPath:@"contentOffset"];
            [self removeObserverForObject:scrollView forKeyPath:@"contentInset"];
            [self removeObserverForObject:scrollView forKeyPath:@"pan.state"];
        }
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Init

- (id)init
{
    self = [super init];
    if (self)
    {
        _scrollPagingEnabled = NO;
        _currentIndex = 0;
        changingOrientationState = NO;
        
        //
        self.contentViewController = [[UIPageViewController alloc]initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                                                                    navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                                                                  options:nil];
        self.contentViewController.dataSource = self;
        self.contentViewController.delegate = self;

        //
        self.scrollView.delegate = self;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(orientationWillChange:)
                                                     name:UIApplicationWillChangeStatusBarOrientationNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(orientationDidChange:)
                                                     name:UIApplicationDidChangeStatusBarOrientationNotification
                                                   object:nil];
    }
    return self;
}

#pragma mark - NSNotification

- (void)orientationWillChange:(NSNotification *)notification
{
    changingOrientationState = YES;
}

- (void)orientationDidChange:(NSNotification *)notification
{
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.0 * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        changingOrientationState = NO;
    });
}

#pragma mark - layout

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (self.contentViewController.view.superview == nil)
    {
        [self.pageViewController addChildViewController:self.contentViewController];
        [self addSubview:self.contentViewController.view];
        [self.contentViewController didMoveToParentViewController:self.pageViewController];
    }

    self.contentViewController.view.frame = self.bounds;
}

#pragma mark - reload

- (void)reloadData
{
    //REMOVE OBSRVER
    for (UIViewController *viewController in self.viewControllers)
    {
        UIScrollView *scrollView = viewController.contentScrollView;
        
        if ([scrollView isKindOfClass:[UIScrollView class]])
        {
            [self removeObserverForObject:scrollView forKeyPath:@"contentOffset"];
            [self removeObserverForObject:scrollView forKeyPath:@"contentInset"];
            [self removeObserverForObject:scrollView forKeyPath:@"pan.state"];
        }
    }
    
    //RELOAD VIEW CONTROLLER
    if ([self.dataSource respondsToSelector:@selector(viewControllersForPageView:)])
    {
        self.viewControllers = [self.dataSource viewControllersForPageView:self];
    }
    
    //ADD OBSRVERS
    for (UIViewController *viewController in self.viewControllers)
    {
        UIScrollView *scrollView = viewController.contentScrollView;
        
        if ([scrollView isKindOfClass:[UIScrollView class]])
        {
            [self addObserverForObject:scrollView
                            forKeyPath:@"contentOffset"
                               options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew];
            
            [self addObserverForObject:scrollView
                            forKeyPath:@"contentInset"
                               options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew];

            
            [self addObserverForObject:scrollView
                            forKeyPath:@"pan.state"
                               options:NSKeyValueObservingOptionNew];

            //
            [self.pageViewController layoutContentInsetForScrollView:scrollView
                                                    atContentOffsetY:CGRectGetMaxY(self.pageViewController.contentHeaderView.frame)];
            [scrollView setContentOffset:CGPointMake(0, -scrollView.contentInset.top) animated:NO];
        }
    }
    
    //DISPLAY
    UIViewController *viewController = [self viewControllerAtIndex:_currentIndex];
    [self.contentViewController setViewControllers:@[viewController]
                                         direction:UIPageViewControllerNavigationDirectionForward
                                          animated:NO
                                        completion:nil];
}

#pragma mark - scrollview delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat width = scrollView.frame.size.width;
    CGFloat index = (_currentIndex == NSNotFound) ? 0 : _currentIndex;
    float position = ((width*index) + (scrollView.contentOffset.x - width))/ width;
    
    if ([self.delegate respondsToSelector:@selector(pageView:didScrollToCurrentPosition:)])
    {
        [self.delegate pageView:self didScrollToCurrentPosition:position];
    }
}

#pragma  mark - pageviewcontroller datasource

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSInteger index = [self indexOfViewController:viewController];
    
    if (index != (self.viewControllers.count - 1) && index != NSNotFound)
    {
        return [self viewControllerAtIndex:index+1];
    }
    return nil;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSInteger index = [self indexOfViewController:viewController];
    
    if (index != 0 && index != NSNotFound)
    {
        return [self viewControllerAtIndex:index-1];
    }
    return nil;
}

#pragma  mark - pageviewcontroller delegate

- (void)pageViewController:(UIPageViewController *)pageViewController
        didFinishAnimating:(BOOL)finished
   previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers
       transitionCompleted:(BOOL)completed
{
    if (completed)
    {
        _currentIndex = [self indexOfViewController:self.contentViewController.viewControllers.firstObject];
        
        if (_currentIndex != NSNotFound)
        {
            if ([self.delegate respondsToSelector:@selector(pageView:didScrollToCurrentIndex:)])
            {
                [self.delegate pageView:self didScrollToCurrentIndex:self.currentIndex];
            }
        }
    }
}

#pragma  mark - KOV

- (void)addObserverForObject:(NSObject *)object forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options
{
    @try {
        [object addObserver:self
                 forKeyPath:keyPath
                    options:options
                    context:KMPagerViewKVOContext];
    }
    @catch (NSException *exception) {}
}

- (void)removeObserverForObject:(NSObject *)object forKeyPath:(NSString *)keyPath
{
    @try {
        [object removeObserver:self
                    forKeyPath:keyPath
                       context:KMPagerViewKVOContext];
    }
    @catch (NSException *exception) {}
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == KMPagerViewKVOContext)
    {
        if ([object isKindOfClass:[UIScrollView class]])
        {
            UIScrollView *scrollView = (UIScrollView*)object;
            
            NSUInteger index = [self indexOfViewController:scrollView.superViewController];
            
            if (index != NSNotFound && index == _currentIndex)
            {
                if ([keyPath isEqualToString:@"contentOffset"])
                {
                    CGPoint new = [change[NSKeyValueChangeNewKey] CGPointValue];
                    CGPoint old = [change[NSKeyValueChangeOldKey] CGPointValue];

                    
//                    NSLog(@"tracking : %@",scrollView.tracking ? @"YES":@"NO");
//                    NSLog(@"dragging : %@",scrollView.dragging ? @"YES":@"NO");
//                    NSLog(@"decelerating : %@",scrollView.decelerating ? @"YES":@"NO");

                    if (new.y != old.y
                        && scrollView.contentOffset.y+scrollView.frame.size.height < scrollView.contentSize.height)
                    {
                        [self.pageViewController scrollView:scrollView didScrollToContentOffset:new fromContentOffset:old];
                    }
                }
                else if ([keyPath isEqualToString:@"contentInset"])
                {
                    UIEdgeInsets new = [change[NSKeyValueChangeNewKey] UIEdgeInsetsValue];
                    UIEdgeInsets old = [change[NSKeyValueChangeOldKey] UIEdgeInsetsValue];
                    
                    if (-old.top == scrollView.contentOffset.y)
                    {
                        [scrollView setContentOffset:CGPointMake(0, -new.top) animated:NO];
                    }
                }
                else if ([keyPath isEqualToString:@"pan.state"])
                {
                    UIGestureRecognizerState state = [change[NSKeyValueChangeNewKey] integerValue];

                    if (state == UIGestureRecognizerStateEnded || state == UIGestureRecognizerStateCancelled)
                    {
                        [self.pageViewController scrollViewDidEndDragging:scrollView];
                    }
                }
            }
        }
    }
    else
    {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}



#pragma mark -

- (UIViewController *)viewControllerAtIndex:(NSInteger)index
{
    if (index < self.viewControllers.count)
    {
        return self.viewControllers[index];
    }
    return nil;
}

- (NSInteger)indexOfViewController:(UIViewController *)viewController
{
    return [self.viewControllers indexOfObject:viewController];
}

#pragma mark - SETTERS

- (void)setCurrentIndex:(NSUInteger)currentIndex animated:(BOOL)animated
{
    if (_currentIndex != currentIndex)
    {
        BOOL isForwards = currentIndex > self.currentIndex;
        NSArray *viewControllers = self.contentViewController.viewControllers;
        UIViewController *viewController = [self viewControllerAtIndex:currentIndex];
        
        typeof(self) __weak weakSelf = self;
        [self.contentViewController setViewControllers:@[viewController]
                                             direction:isForwards ? UIPageViewControllerNavigationDirectionForward : UIPageViewControllerNavigationDirectionReverse
                                              animated:YES
                                            completion:^(BOOL finished) {
                                                typeof(weakSelf) __strong strongSelf = weakSelf;
                                                [strongSelf pageViewController:strongSelf.contentViewController
                                                            didFinishAnimating:YES
                                                       previousViewControllers:viewControllers
                                                           transitionCompleted:YES];
                                            }];
    }
}

- (void)setCurrentIndex:(NSUInteger)currentIndex
{
    [self setCurrentIndex:currentIndex animated:NO];
}

- (void)setScrollPagingEnabled:(BOOL)scrollPagingEnabled
{
    if (self.scrollView.scrollEnabled != scrollPagingEnabled)
    {
        self.scrollView.scrollEnabled = scrollPagingEnabled;
    }
}
#pragma mark - GETTERS

- (UIViewController*)currentViewController
{
    return [self viewControllerAtIndex:self.currentIndex];
}

- (BOOL)scrollPagingEnabled
{
    return self.scrollView.scrollEnabled;
}

- (NSInteger)numberOfPage
{
    return self.viewControllers.count;
}

- (KMPageViewController*)pageViewController
{
    if (!_pageViewController)
    {
        for (UIView* next = self; next; next = next.superview)
        {
            UIResponder* nextResponder = [next nextResponder];
            
            if ([nextResponder isKindOfClass:[KMPageViewController class]])
            {
                _pageViewController = (KMPageViewController*)nextResponder;
            }
        }
    }
    
    return _pageViewController;
}

- (UIScrollView *)scrollView
{
    if (!_scrollView)
    {
        for (UIView *subview in self.contentViewController.view.subviews)
        {
            if ([subview isKindOfClass:[UIScrollView class]]) {
                _scrollView = (UIScrollView *)subview;
                break;
            }
        }
    }
    return _scrollView;
}


@end
