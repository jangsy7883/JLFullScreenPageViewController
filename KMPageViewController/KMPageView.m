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

- (void)addContentViewController:(UIViewController *)viewController;
- (void)removeContentViewController:(UIViewController *)viewController;

@end

@interface KMPageView ()
{
    BOOL changingOrientationState;
    NSInteger tempIndex;
}

@property (nonatomic, readonly) NSInteger count;
@property (nonatomic, strong) NSMutableDictionary *viewInfos;

@property (nonatomic, weak) KMPageViewController *pageViewController;

@end

@implementation KMPageView

@dynamic delegate;

static void * const KMPagerViewKVOContext = (void*)&KMPagerViewKVOContext;

#pragma mark - memory

- (void)dealloc
{
    self.viewInfos = nil;
    
    @try {
        [self removeObserver:self forKeyPath:@"contentOffset" context:KMPagerViewKVOContext];
        [self removeObserver:self forKeyPath:@"frame" context:KMPagerViewKVOContext];
    }
    @catch (NSException *exception) {}
    
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
        
        self.viewInfos = [NSMutableDictionary dictionary];
        
        self.scrollsToTop = NO;
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

    CGSize size = CGSizeMake(CGRectGetWidth(self.bounds) * self.count, CGRectGetHeight(self.bounds));
    
    if (CGSizeEqualToSize(size, self.contentSize) == NO)
    {
        self.contentSize = size;
        [self setContentOffset:CGPointMake(CGRectGetWidth(self.bounds)*_currentIndex, 0) animated:NO];
    }
    
    for (NSNumber *key in [self.viewInfos allKeys])
    {
        UIViewController *viewController = self.viewInfos[key];
        NSInteger index = [key integerValue];
        
        [self layoutWithViewController:viewController forIndex:index];
    }
}

- (void)layoutWithViewController:(UIViewController*)viewController forIndex:(NSInteger)index
{
    CGRect rect  = CGRectMake(CGRectGetWidth(self.bounds) * index,
                              0,
                              CGRectGetWidth(self.bounds),
                              CGRectGetHeight(self.bounds));
    
    if (!CGRectEqualToRect(viewController.view.frame, rect))
    {
        viewController.view.frame = rect;
    }
}

#pragma mark - reload

- (void)reloadData
{
    //REMOVE
    [self.viewInfos removeAllObjects];
    
    for (UIViewController *viewController in self.pageViewController.childViewControllers)
    {
        [self.pageViewController removeContentViewController:viewController];
    }
    
    [self reloadPageAtIndex:_currentIndex];
    [self reloadPageAtIndex:_currentIndex+1];
    
    if ([self.delegate respondsToSelector:@selector(pageViewCurrentIndexDidChange:)])
    {
        [self.delegate pageViewCurrentIndexDidChange:self];
    }
}

- (void)reloadPageAtIndex:(NSUInteger)index
{
    if ([self.dataSource respondsToSelector:@selector(pageView:viewControllerForPageAtIndex:)] == NO || index == NSNotFound)
    {
        return;
    }
    
    UIViewController *viewController = [self.dataSource pageView:self viewControllerForPageAtIndex:index];
    
    if (viewController && viewController.parentViewController == nil)
    {
        //INSERT
        [self.pageViewController addContentViewController:viewController];
        
        [self.viewInfos setObject:viewController forKey:@(index)];
    }
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (_currentIndex == NSNotFound) return;
    
    if (context == KMPagerViewKVOContext)
    {
        if ([keyPath isEqualToString:@"contentOffset"])
        {
            CGPoint new = [change[NSKeyValueChangeNewKey] CGPointValue];
            CGPoint old = [change[NSKeyValueChangeOldKey] CGPointValue];
            
            if (new.x != old.x)
            {
                if ([self.delegate respondsToSelector:@selector(pageViewDidScroll:)])
                {
                    [self.delegate pageViewDidScroll:self];
                }

                NSInteger index = lround(self.contentOffset.x / self.frame.size.width);
                
                [self reloadPageAtIndex:index];
                [self reloadPageAtIndex:index-1];
                [self reloadPageAtIndex:index+1];
                
                if (_currentIndex != index && changingOrientationState == NO)
                {
                    _currentIndex = index;
                    
                    for (NSNumber *key in [self.viewInfos allKeys])
                    {
                        NSInteger index = [key integerValue];
                        UIViewController *viewController = self.viewInfos[key];
                        viewController.contentScrollView.scrollsToTop = (index == _currentIndex);
                    }
                    
                    if ([self.delegate respondsToSelector:@selector(pageViewCurrentIndexDidChange:)])
                    {
                        [self.delegate pageViewCurrentIndexDidChange:self];
                    }
                }
            }
        }
        else if ([keyPath isEqualToString:@"frame"])
        {
            CGRect rect = [change[NSKeyValueChangeNewKey] CGRectValue];
            if (!CGRectEqualToRect(rect, self.frame))
            {
                [self reloadPageAtIndex:_currentIndex];
                [self setContentOffset:CGPointMake(CGRectGetWidth(self.bounds)*_currentIndex, 0) animated:NO];
            }
        }
    }
    else
    {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - SETTERS

- (void)setCurrentIndex:(NSUInteger)currentIndex animated:(BOOL)animated
{
    CGSize size = CGSizeMake(CGRectGetWidth(self.bounds) * self.count, CGRectGetHeight(self.bounds));
    
    if (CGSizeEqualToSize(size, self.contentSize) == NO)
    {
        self.contentSize = size;
    }

    [self setContentOffset:CGPointMake(CGRectGetWidth(self.bounds)*currentIndex, 0) animated:animated];
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

- (NSArray*)visibleViewContollers
{
    return [self.pageViewController childViewControllers];
}

- (BOOL)scrollPagingEnabled
{
    return self.scrollEnabled;
}

- (NSInteger)count
{
    if ([self.dataSource respondsToSelector:@selector(numberOfPageInPageView:)])
    {
        return [self.dataSource numberOfPageInPageView:self];
    }
    return 0;
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

@end
