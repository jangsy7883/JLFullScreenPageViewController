//
//  KMContentView.m
//  KMSegmentedPager
//
//  Created by IM049 on 2015. 9. 4..
//  Copyright (c) 2015년 Jangsy7883. All rights reserved.
//

#import "KMContentView.h"

typedef NS_ENUM(NSInteger, KMPanGestureDirection)
{
    KMPanGestureDirectionNone  = 1 << 0,
    KMPanGestureDirectionRight = 1 << 1,
    KMPanGestureDirectionLeft  = 1 << 2,
    KMPanGestureDirectionUp    = 1 << 3,
    KMPanGestureDirectionDown  = 1 << 4
};

@interface KMContentView ()<UIScrollViewDelegate>
{
    BOOL _isObserving;
    BOOL _lock;
}

@property (nonatomic, strong) NSMutableArray *observedViews;
@property (nonatomic, readonly) CGFloat minimumTopOffset;

@end

@implementation KMContentView

@dynamic delegate;
static void * const KMScrollViewKVOContext = (void*)&KMScrollViewKVOContext;

#pragma mark - memory

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - init

- (id)init
{
    self = [super init];
    if (self)
    {
        self.scrollsToTop = YES;
        self.alwaysBounceVertical = NO;
        self.showsVerticalScrollIndicator = NO;
        self.directionalLockEnabled = YES;
        
        self.observedViews = [NSMutableArray array];
    }
    return self;
}

- (void)setContentOffset:(CGPoint)contentOffset
{
    if ((contentOffset.y >= -self.minimumTopOffset))
    {
        contentOffset.y = -self.minimumTopOffset;
    }
    [super setContentOffset:contentOffset];
}

#pragma mark - scroll

- (void)updateContentOffset
{
//    if ((self.contentOffset.y >= -self.minimumTopOffset))
//    {
//        self.contentOffset = CGPointMake(self.contentOffset.x, -self.minimumTopOffset);
//    }
}

- (void)endDecelerating
{
    _lock = NO;
    [self removeObservedViews];
}

- (void)scrollView:(UIScrollView*)scrollView setContentOffset:(CGPoint)offset
{
    _isObserving = NO;
    scrollView.contentOffset = offset;
    _isObserving = YES;
}

#pragma mark - KOV

- (void)addObservedView:(UIView *)view
{
    if (![self.observedViews containsObject:view])
    {
        [self.observedViews addObject:view];
        [self addObserverToView:view];
    }
}

- (void) removeObservedViews
{
    for (UIView *view in self.observedViews)
    {
        [self removeObserverFromView:view];
    }
    [self.observedViews removeAllObjects];
}

- (void) addObserverToView:(UIView *)view
{
    _isObserving = NO;
    if ([view isKindOfClass:[UIScrollView class]])
    {
        [view addObserver:self
               forKeyPath:@"contentOffset"
                  options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew
                  context:KMScrollViewKVOContext];
    }
    _isObserving = YES;
}

- (void) removeObserverFromView:(UIView *)view
{
    @try {
        if ([view isKindOfClass:[UIScrollView class]])
        {
            [view removeObserver:self
                      forKeyPath:@"contentOffset"
                         context:KMScrollViewKVOContext];
        }
    }
    @catch (NSException *exception) {}
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == KMScrollViewKVOContext && [keyPath isEqualToString:@"contentOffset"])
    {
        CGPoint new = [[change objectForKey:NSKeyValueChangeNewKey] CGPointValue];
        CGPoint old = [[change objectForKey:NSKeyValueChangeOldKey] CGPointValue];
        
        if (old.y == new.y) return;
        
        if (_isObserving && object == self)
        {
            if ((old.y - new.y) > 0 && _lock)
            {
                if (old.y <= -self.contentInset.top)
                {
                    old.y = MAX(MIN(old.y, new.y), -self.contentInset.top);

                    [self scrollView:self setContentOffset:old];
                }
            }
            else if (new.y <= -self.contentInset.top && !_lock && (old.y - new.y) > 0)
            {
                old.y = MAX(MIN(old.y, new.y), -self.contentInset.top);

                [self scrollView:self setContentOffset:old];
            }

            if ((old.y - new.y) > 0 && _lock)
            {
                
                [self scrollView:self setContentOffset:old];
            }
        }
        else if (_isObserving && [object isKindOfClass:[UIScrollView class]])
        {
            UIScrollView *scrollView = object;
            _lock = !(scrollView.contentOffset.y <= -scrollView.contentInset.top);

            if (self.contentOffset.y < -self.minimumTopOffset && _lock && (old.y - new.y) < 0)
            {
                [self scrollView:scrollView setContentOffset:old];
            }

            if (!_lock && (-self.contentOffset.y != self.contentInset.top))
            {
                [self scrollView:scrollView setContentOffset:CGPointMake(scrollView.contentOffset.x, -scrollView.contentInset.top)];
            }
        }
    }
    else
    {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]])
    {
        KMPanGestureDirection direction = [self getDirectionOfPanGestureRecognizer:(UIPanGestureRecognizer*)gestureRecognizer];
        
        if (direction == KMPanGestureDirectionLeft || direction == KMPanGestureDirectionRight)
        {
            return NO;
        }
    }
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    [self addObservedView:otherGestureRecognizer.view];
    
    return YES;
}

- (KMPanGestureDirection) getDirectionOfPanGestureRecognizer:(UIPanGestureRecognizer*) panGestureRecognizer
{
    CGPoint velocity = [panGestureRecognizer velocityInView:self];
    CGFloat absX = fabs(velocity.x);
    CGFloat absY = fabs(velocity.y);
    
    if (absX > absY) {
        return (velocity.x > 0)? KMPanGestureDirectionRight : KMPanGestureDirectionLeft;
    }
    else if (absX < absY) {
        return (velocity.y > 0)? KMPanGestureDirectionDown : KMPanGestureDirectionUp;
    }
    return KMPanGestureDirectionNone;
}

#pragma mark - KVO


#pragma mark - GETTERS

- (CGFloat)minimumTopOffset
{
    if ([self.dataSource respondsToSelector:@selector(minimumTopOffsetInContentView:)])
    {
        return [self.dataSource minimumTopOffsetInContentView:self];
    }
    return 0;
}

@end
