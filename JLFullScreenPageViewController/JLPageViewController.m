//
//  KMPagerView.m
//  JLFullScreenPageViewController
//
//  Created by Jangsy7883 on 2015. 9. 4..
//  Copyright © 2015년 Dalkomm. All rights reserved.
//

#import "JLPageViewController.h"
#import "JLFullScreenPageViewController.h"
#import "UIViewController+JLFSAdditions.h"

@interface JLFullScreenPageViewController ()

@property (nonatomic, readonly) UIView *contentHeaderView;

- (void)layoutContentInsetForScrollView:(UIScrollView*)scrollView atContentInsetTop:(CGFloat)insetTop;

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView;
- (void)scrollView:(UIScrollView*)scrollView didScrollToContentOffset:(CGPoint)toContentOffset fromContentOffset:(CGPoint)formContentOffset;

@end

@interface JLPageViewController () <UIPageViewControllerDataSource, UIPageViewControllerDelegate,UIScrollViewDelegate>

@property (nonatomic, strong) UIPageViewController *pageViewController;

@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, weak) JLFullScreenPageViewController *fullScreenPageViewController;

@property (nonatomic, strong) NSArray *viewControllers;



@end

@implementation JLPageViewController

static void * const KMPagerViewKVOContext = (void*)&KMPagerViewKVOContext;

#pragma mark - memory

- (void)dealloc
{
    for (UIViewController *viewController in self.viewControllers)
    {
        UIScrollView *scrollView = viewController.jl_scrollView;
        
        if ([scrollView isKindOfClass:[UIScrollView class]])
        {
            [self removeObserverForObject:scrollView forKeyPath:@"contentOffset"];
            [self removeObserverForObject:scrollView forKeyPath:@"contentInset"];
            [self removeObserverForObject:scrollView forKeyPath:@"pan.state"];
        }
    }
}

#pragma mark - Init

- (id)init
{
    self = [super init];
    if (self)
    {
        _scrollPagingEnabled = NO;
        _currentIndex = 0;
    }
    return self;
}

#pragma mark - view lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.pageViewController = [[UIPageViewController alloc]initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                                                             navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                                                           options:nil];
    self.pageViewController.dataSource = self;
    self.pageViewController.delegate = self;
    [self addChildViewController:self.pageViewController];
    [self.view addSubview:self.pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
    
    //
    self.scrollView.scrollsToTop = NO;
    self.scrollView.delegate = self;
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    self.pageViewController.view.frame = self.view.bounds;
}

#pragma mark - reload

- (void)reloadData
{
    //REMOVE OBSRVER
    for (UIViewController *viewController in self.viewControllers)
    {
        UIScrollView *scrollView = viewController.jl_scrollView;
        
        if ([scrollView isKindOfClass:[UIScrollView class]])
        {
            [self removeObserverForObject:scrollView forKeyPath:@"contentOffset"];
            [self removeObserverForObject:scrollView forKeyPath:@"contentInset"];
            [self removeObserverForObject:scrollView forKeyPath:@"pan.state"];
        }
    }
    
    //RELOAD VIEW CONTROLLER
    if ([self.dataSource respondsToSelector:@selector(viewControllersForPageViewController:)])
    {
        self.viewControllers = [self.dataSource viewControllersForPageViewController:self];
    }
    
    //ADD OBSRVERS
    for (UIViewController *viewController in self.viewControllers)
    {
        UIScrollView *scrollView = viewController.jl_scrollView;
        
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
            [self.fullScreenPageViewController layoutContentInsetForScrollView:scrollView
                                                             atContentInsetTop:CGRectGetMaxY(self.fullScreenPageViewController.contentHeaderView.frame)];
            [scrollView setContentOffset:CGPointMake(0, -scrollView.contentInset.top) animated:NO];
        }
    }
    
    //DISPLAY
    if ([self.dataSource respondsToSelector:@selector(defaultPageIndexForPageViewController:)])
    {
        _currentIndex = [self.dataSource defaultPageIndexForPageViewController:self];
    }
    
    UIViewController *viewController = [self viewControllerAtIndex:_currentIndex];
    
    if (viewController)
    {
        [self.pageViewController setViewControllers:@[viewController]
                                          direction:UIPageViewControllerNavigationDirectionForward
                                           animated:NO
                                         completion:nil];
        
        if ([self.delegate respondsToSelector:@selector(pageViewController:didScrollToCurrentPosition:)] )
        {
            [self.delegate pageViewController:self didScrollToCurrentPosition:_currentIndex];
        }
        if ([self.delegate respondsToSelector:@selector(pageViewController:didChangeToCurrentIndex:fromIndex:)])
        {
            [self.delegate pageViewController:self didChangeToCurrentIndex:_currentIndex fromIndex:NSNotFound];
        }
    }
}

#pragma mark - scrollview delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([self.delegate respondsToSelector:@selector(pageViewController:didScrollToCurrentPosition:)] )
    {
        NSUInteger nextIndex = _nextIndex;
        NSUInteger index = (_currentIndex == NSNotFound) ? 0 : _currentIndex;
        CGFloat offsetX = scrollView.contentOffset.x;
        CGFloat width = scrollView.frame.size.width;
        CGFloat position = 0;
        CGFloat percent = fabs(offsetX - width)/width;
        
        if (index < nextIndex)
        {
            position = ((nextIndex - index) * percent) + index;
        }
        else if (index > nextIndex)
        {
            position = ((index - nextIndex) * (1-percent)) + nextIndex;
        }
        else
        {
            position = index;
        }
        
        [self.delegate pageViewController:self didScrollToCurrentPosition:position];
    }
}

#pragma  mark - pageviewcontroller datasource

- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray *)pendingViewControllers
{
    _nextIndex = [self indexOfViewController:pendingViewControllers.firstObject];
}

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
        NSUInteger fromIndex = _currentIndex;
        _currentIndex = [self indexOfViewController:self.pageViewController.viewControllers.firstObject];
        
        for (UIViewController *viewController in self.pageViewController.childViewControllers)
        {
            NSUInteger index =  [self indexOfViewController:viewController];
        
            UIScrollView *scrollView = viewController.jl_scrollView;
            
            if (index == NSNotFound && scrollView)
            {
                scrollView.scrollsToTop = (_currentIndex == index);
            }
        }
        if (_currentIndex != NSNotFound)
        {
            if ([self.delegate respondsToSelector:@selector(pageViewController:didChangeToCurrentIndex:fromIndex:)])
            {
                [self.delegate pageViewController:self didChangeToCurrentIndex:self.currentIndex fromIndex:fromIndex];
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
            
            NSUInteger index = [self indexOfViewController:scrollView.jl_superViewController];
            
            if ([keyPath isEqualToString:@"contentInset"])
            {
                UIEdgeInsets new = [change[NSKeyValueChangeNewKey] UIEdgeInsetsValue];
                UIEdgeInsets old = [change[NSKeyValueChangeOldKey] UIEdgeInsetsValue];
                
                if (-old.top == scrollView.contentOffset.y)
                {
                    [scrollView setContentOffset:CGPointMake(0, -new.top) animated:NO];
                }
            }
            else if (index != NSNotFound && index == _currentIndex)
            {
                if ([keyPath isEqualToString:@"contentOffset"])
                {
                    CGPoint new = [change[NSKeyValueChangeNewKey] CGPointValue];
                    CGPoint old = [change[NSKeyValueChangeOldKey] CGPointValue];
                    
                    if (new.y != old.y
                        && scrollView.contentOffset.y+scrollView.frame.size.height < scrollView.contentSize.height)
                    {
                        [self.fullScreenPageViewController scrollView:scrollView didScrollToContentOffset:new fromContentOffset:old];
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
                        [self.fullScreenPageViewController scrollViewDidEndDragging:scrollView];
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
    if (self.viewControllers.count > 0 && index < self.viewControllers.count)
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
        UIViewController *viewController = [self viewControllerAtIndex:currentIndex];

        if (viewController)
        {
            _nextIndex = currentIndex;
            
            typeof(self) __weak weakSelf = self;
            BOOL isForwards = currentIndex > self.currentIndex;
            NSArray *viewControllers = self.pageViewController.viewControllers;

            dispatch_async(dispatch_get_main_queue(), ^{
                [self.pageViewController setViewControllers:@[viewController]
                                                  direction:isForwards ? UIPageViewControllerNavigationDirectionForward : UIPageViewControllerNavigationDirectionReverse
                                                   animated:animated
                                                 completion:^(BOOL finished)
                 {
                     typeof(weakSelf) __strong strongSelf = weakSelf;
                     [strongSelf pageViewController:strongSelf.pageViewController
                                 didFinishAnimating:animated
                            previousViewControllers:viewControllers
                                transitionCompleted:YES];
                 }];
            });
        }

/*
        BOOL isForwards = currentIndex > self.currentIndex;
        NSArray *viewControllers = self.pageViewController.viewControllers;
        UIViewController *viewController = [self viewControllerAtIndex:currentIndex];
        
        typeof(self) __weak weakSelf = self;
        __weak UIPageViewController* pvcw = self.pageViewController;
        
        [self.pageViewController setViewControllers:@[viewController]
                                          direction:isForwards ? UIPageViewControllerNavigationDirectionForward : UIPageViewControllerNavigationDirectionReverse
                                           animated:animated
                                         completion:^(BOOL finished) {
                                             typeof(weakSelf) __strong strongSelf = weakSelf;
                                             [strongSelf pageViewController:strongSelf.pageViewController
                                                         didFinishAnimating:YES
                                                    previousViewControllers:viewControllers
                                                        transitionCompleted:YES];
                                             
                                             UIPageViewController* pvcs = pvcw;
                                             if (!pvcs) return;
                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                 [pvcs setViewControllers:@[viewController]
                                                                direction:isForwards ? UIPageViewControllerNavigationDirectionForward : UIPageViewControllerNavigationDirectionReverse
                                                                 animated:NO
                                                               completion:nil];
                                             });
                                             
                                         }];
 */
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

- (JLFullScreenPageViewController*)fullScreenPageViewController
{
    if (!_fullScreenPageViewController)
    {
        for (UIView* next = self.view; next; next = next.superview)
        {
            UIResponder* nextResponder = [next nextResponder];
            
            if ([nextResponder isKindOfClass:[JLFullScreenPageViewController class]])
            {
                _fullScreenPageViewController = (JLFullScreenPageViewController*)nextResponder;
            }
        }
    }
    
    return _fullScreenPageViewController;
}

- (UIScrollView *)scrollView
{
    if (!_scrollView)
    {
        for (UIView *subview in self.pageViewController.view.subviews)
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
