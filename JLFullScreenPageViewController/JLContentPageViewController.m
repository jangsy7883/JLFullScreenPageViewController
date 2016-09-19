//
//  KMPagerView.m
//  JLFullScreenPageViewController
//
//  Created by Jangsy7883 on 2015. 9. 4..
//  Copyright © 2015년 Dalkomm. All rights reserved.
//

#import "JLContentPageViewController.h"
#import "JLFullScreenPageViewController.h"
#import "UIViewController+JLFSAdditions.h"

@interface JLFullScreenPageViewController ()

@property (nonatomic, readonly) UIView *contentHeaderView;

- (void)layoutContentInsetForScrollView:(UIScrollView*)scrollView atContentInsetTop:(CGFloat)insetTop;

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView;
- (void)scrollView:(UIScrollView*)scrollView didScrollToContentOffset:(CGPoint)toContentOffset fromContentOffset:(CGPoint)formContentOffset;

@end

@interface JLPageViewController ()

- (void)removeObservers;

@end

@interface JLContentPageViewController ()

@property (nonatomic, weak) JLFullScreenPageViewController *fullScreenPageViewController;
@property (nonatomic, strong) NSArray *contentViewControllers;

@end

@implementation JLContentPageViewController

@dynamic dataSource;

static void * const KMPagerViewKVOContext = (void*)&KMPagerViewKVOContext;

#pragma mark - memory

- (void)dealloc
{
    [super removeObservers];
    
    for (UIViewController *viewController in self.contentViewControllers)
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

#pragma mark - reload

- (void)reloadData
{
    //RESET VIEWCONTROLLER
    for (UIViewController *viewController in self.contentViewControllers)
    {
        UIScrollView *scrollView = viewController.jl_scrollView;
        
        if ([scrollView isKindOfClass:[UIScrollView class]])
        {
            [self removeObserverForObject:scrollView forKeyPath:NSStringFromSelector(@selector(contentOffset))];
            [self removeObserverForObject:scrollView forKeyPath:NSStringFromSelector(@selector(contentInset))];
            [self removeObserverForObject:scrollView forKeyPath:@"pan.state"];
        }
    }
    
    //RELOAD VIEW CONTROLLER
    if ([self.dataSource respondsToSelector:@selector(contentViewControllersForPageViewController:)])
    {
        self.contentViewControllers = [self.dataSource contentViewControllersForPageViewController:self];
    }
    
    for (UIViewController *viewController in self.contentViewControllers)
    {
        UIScrollView *scrollView = viewController.jl_scrollView;
        
        if ([scrollView isKindOfClass:[UIScrollView class]])
        {
            [self addObserverForObject:scrollView
                            forKeyPath:NSStringFromSelector(@selector(contentOffset))
                               options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew];
            
            [self addObserverForObject:scrollView
                            forKeyPath:NSStringFromSelector(@selector(contentInset))
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

    [super reloadData];
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
            else if (index != NSNotFound && index == self.currentIndex)
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

- (NSInteger)indexOfViewController:(UIViewController *)viewController
{
    return [self.contentViewControllers indexOfObject:viewController];
}

#pragma mark - GETTERS

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

@end
