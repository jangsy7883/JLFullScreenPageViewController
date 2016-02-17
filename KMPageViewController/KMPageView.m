//
//  KMPagerView.m
//  KMSegmentedPager
//
//  Created by IM049 on 2015. 9. 4..
//  Copyright (c) 2015년 Jangsy7883. All rights reserved.
//

#import "KMPageView.h"
#import "KMPageViewController.h"

@interface KMPageViewController ()

- (void)addChildScrollView:(UIScrollView *)scrollView;
- (void)removeChildScrollView:(UIScrollView *)scrollView;

@end
@interface UIView (KMPageView)

@property (nonatomic, readonly) UIViewController *superViewController;
@property (nonatomic, readonly) KMPageViewController *pageViewController;

@end

@implementation UIView (KMPageView)

- (KMPageViewController*)pageViewController
{
    for (UIView* next = self; next; next = next.superview)
    {
        UIResponder* nextResponder = [next nextResponder];
        
        if ([nextResponder isKindOfClass:[KMPageViewController class]])
        {
            return (KMPageViewController*)nextResponder;
        }
    }

    return nil;
}

- (UIViewController*)superViewController
{
    for (UIView* next = self; next; next = next.superview)
    {
        UIResponder* nextResponder = [next nextResponder];
        
        if ([nextResponder isKindOfClass:[UIViewController class]])
        {
            return (UIViewController*)nextResponder;
        }
    }
    return nil;
}

@end

@interface KMPageView ()

@property (nonatomic, readonly) NSInteger count;
@property (nonatomic, readonly) NSArray *viewControllers;
@end

@implementation KMPageView

@dynamic delegate;

static void * const KMPagerViewKVOContext = (void*)&KMPagerViewKVOContext;

#pragma mark - memory

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"contentOffset" context:KMPagerViewKVOContext];
    [self removeObserver:self forKeyPath:@"frame" context:KMPagerViewKVOContext];
}

#pragma mark - Init

- (id)init
{
    self = [super init];
    if (self)
    {
        _scrollPagingEnabled = NO;
        _currentIndex = NSNotFound;
        
        self.scrollsToTop = YES;
        self.pagingEnabled = YES;
        self.directionalLockEnabled = YES;
        self.alwaysBounceVertical = NO;
        self.alwaysBounceHorizontal = NO;
        self.showsVerticalScrollIndicator = NO;
        self.showsHorizontalScrollIndicator = NO;
        self.keyboardDismissMode = UIScrollViewKeyboardDismissModeNone;
        self.scrollEnabled = NO;
        
        [self addObserver:self
               forKeyPath:@"contentOffset"
                  options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                  context:KMPagerViewKVOContext];
        
        [self addObserver:self
               forKeyPath:@"frame"
                  options:NSKeyValueObservingOptionNew
                  context:KMPagerViewKVOContext];
        
    }
    return self;
}

#pragma mark - view lifeCycle

- (void)layoutSubviews
{
    [super layoutSubviews];

    CGSize size = CGSizeMake(CGRectGetWidth(self.bounds) * self.count, CGRectGetHeight(self.bounds));
    
    if (CGSizeEqualToSize(size, self.contentSize) == NO)
    {
        self.contentSize = size;
    }
}

#pragma mark - reload

- (void)reloadData
{
    for (UIView *view in self.subviews)
    {
        
        [view removeFromSuperview];
        [self.pageViewController removeChildScrollView:(UIScrollView*)view];
        
        [view.superViewController willMoveToParentViewController:nil];
        [view.superViewController removeFromParentViewController];
    }
    
    [self reloadPageAtIndex:_currentIndex];
}

- (void)reloadPageAtIndex:(NSUInteger) index
{
    if ([self.dataSource respondsToSelector:@selector(pageView:viewControllerForPageAtIndex:)] == NO || index == NSNotFound)
    {
        return;
    }
    
    for (int i = 0; i < self.count; i++)
    {
        UIViewController *viewController = [self.dataSource pageView:self viewControllerForPageAtIndex:i];
        
        if (viewController)
        {
            if (i <= (int)index+1 && i >= (int)index-1)
            {                
                viewController.view.frame = CGRectMake(CGRectGetWidth(self.bounds) * i,
                                                       0,
                                                       CGRectGetWidth(self.bounds),
                                                       CGRectGetHeight(self.bounds));
                
                if (viewController.parentViewController == nil)
                {
                    [self addSubview:viewController.view];
                    NSLog(@"_______");
                    [self.pageViewController addChildScrollView:(UIScrollView*)viewController.view];
                    [self.pageViewController addChildViewController:viewController];
                    [viewController didMoveToParentViewController:self.pageViewController];
                }
            }
        }
    }
}

#pragma mark - scroll

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (_currentIndex == NSNotFound) return;
    
    if (context == KMPagerViewKVOContext)
    {
        if ([keyPath isEqualToString:@"contentOffset"])
        {
            CGPoint new = [[change objectForKey:NSKeyValueChangeNewKey] CGPointValue];
            CGPoint old = [[change objectForKey:NSKeyValueChangeOldKey] CGPointValue];
            
            if (new.x != old.x)
            {
                [self setCurrentIndex:lround(self.contentOffset.x / self.frame.size.width)
                             animated:NO
                             isScroll:NO];
            }
        }
        else if ([keyPath isEqualToString:@"frame"])
        {
            [self reloadPageAtIndex:_currentIndex];
            [self setContentOffset:CGPointMake(CGRectGetWidth(self.bounds)*_currentIndex, 0) animated:NO];
        }
    }
    else
    {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - SETTERS

- (void)setCurrentIndex:(NSUInteger)currentIndex animated:(BOOL)animated isScroll:(BOOL)isScroll
{
    if (_currentIndex != currentIndex)
    {
        _currentIndex = currentIndex;
        
        [self reloadPageAtIndex:currentIndex];
        
        if (isScroll)
        {
            [self setContentOffset:CGPointMake(CGRectGetWidth(self.bounds)*currentIndex, 0) animated:animated];
        }
        
        if ([self.delegate respondsToSelector:@selector(pageViewCurrentIndexDidChange:)])
        {
            [self.delegate pageViewCurrentIndexDidChange:self];
        }
    }
}

- (void)setCurrentIndex:(NSUInteger)currentIndex animated:(BOOL)animated
{
    [self setCurrentIndex:currentIndex animated:animated isScroll:YES];
}

- (void)setCurrentIndex:(NSUInteger)currentIndex
{
    [self setCurrentIndex:currentIndex animated:NO];
}

- (void)setScrollPagingEnabled:(BOOL)scrollPagingEnabled
{
    if (self.scrollEnabled != scrollPagingEnabled)
    {
        self.scrollEnabled = scrollPagingEnabled;
    }
}

#pragma mark - GETTERS

- (BOOL)scrollPagingEnabled
{
    return self.scrollEnabled;
}

- (NSInteger)count
{
    if ([self.dataSource respondsToSelector:@selector(countInPagerView:)])
    {
        return [self.dataSource countInPagerView:self];
    }
    return 0;
}

@end
