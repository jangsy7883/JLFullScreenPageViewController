//
//  KMSegmentedPager.m
//  KMSegmentedPager
//
//  Created by IM049 on 2015. 9. 4..
//  Copyright (c) 2015년 Jangsy7883. All rights reserved.
//

#import "KMSegmentedPager.h"

#define KMSEGMENTED_PAGER_NAVIGATION_BAR_HEIGHT 44+20

@interface KMSegmentedPager () <KMPageViewDataSource,KMPageViewDelegate,KMContentViewDataSource>

@property (nonatomic, strong) KMPageView *pageView;
@property (nonatomic, strong) KMContentView *contentView;
@property (nonatomic, strong) NSArray *viewControllers;
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, readonly) UIEdgeInsets contentInset;

@end

@implementation KMSegmentedPager

#pragma mark - init

- (id)init
{
    self = [super init];
    if (self)
    {
        _index = 0;
        _navigationBarHeight = KMSEGMENTED_PAGER_NAVIGATION_BAR_HEIGHT;
        _minimumTopOffset = [[UIApplication sharedApplication] statusBarFrame].size.height;
    }
    return self;
}

#pragma mark - view lifecycle

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (CGRectEqualToRect(self.contentView.frame, self.bounds) == NO)
    {
        //SCROLLVIEW CONTENTSIZE
        self.contentView.frame = self.bounds;
        self.contentView.contentSize = self.bounds.size;
        [self reloadScrollViewContentInset];
        
        //PAGE
        self.pageView.frame = CGRectMake(0,
                                         self.segmentedBar.bounds.size.height,
                                         CGRectGetWidth(self.bounds),
                                         CGRectGetHeight(self.bounds) - self.segmentedBar.bounds.size.height - _minimumTopOffset);
        
        [self layoutSubviewsWithScrollView:self.contentView];
    }
}

- (void)layoutSubviewsWithScrollView:(UIScrollView*)scrollView
{
    //NAVIGATION BAR
    if (self.navigationBar != nil)
    {
        self.navigationBar.frame = CGRectMake(0,
                                              MIN(0, -(scrollView.contentOffset.y+scrollView.contentInset.top)),
                                              CGRectGetWidth(self.bounds),
                                              _navigationBarHeight);

        CGFloat minimumLocation = self.minimumTopOffset - CGRectGetHeight(self.navigationBar.frame);
        CGFloat alpha = -(CGRectGetMinY(self.navigationBar.frame) - minimumLocation) / minimumLocation;

        [self setNavigationBarItemsAlpha:alpha];
    }

    //SEGMENTED
    self.segmentedBar.frame = CGRectMake(0,
                                          CGRectGetMaxY(self.navigationBar.frame),
                                          CGRectGetWidth(self.bounds),
                                          self.segmentedBar.bounds.size.height);
}

#pragma mark - reload

- (void) reloadScrollViewContentInset
{
    UIEdgeInsets inset = UIEdgeInsetsZero;

    if (self.navigationBar)
    {
        inset = UIEdgeInsetsMake(_navigationBarHeight, 0, 0, 0);
    }
    else
    {
        inset = UIEdgeInsetsZero;
    }
    
    if (UIEdgeInsetsEqualToEdgeInsets(self.contentView.contentInset, inset) == NO)
    {
        self.contentView.contentInset = inset;

        [self layoutIfNeeded];
        [self setNeedsLayout];
    }
}

- (void) reloadDataWithViewControllers:(NSArray*)viewControllers
{
    self.viewControllers = viewControllers;
    
    [self.pageView reloadData];
}

#pragma mark - ScrollView delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([scrollView isKindOfClass:[KMContentView class]])
    {
        [(KMContentView*)scrollView updateContentOffset];

        [self layoutSubviewsWithScrollView:scrollView];
        
        if ([self.delegate respondsToSelector:@selector(segmentedPager:scrollViewDidScroll:)])
        {
            [self.delegate segmentedPager:self scrollViewDidScroll:self.contentView];
        }
    }
    else if ([scrollView isKindOfClass:[KMPageView class]])
    {
        if ([self.delegate respondsToSelector:@selector(segmentedPager:pageViewDidScroll:)])
        {
            [self.delegate segmentedPager:self pageViewDidScroll:self.pageView];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if ([scrollView isKindOfClass:[KMContentView class]])
    {
        [(KMContentView*)scrollView  endDecelerating];
    }
}

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView
{
    if ([scrollView isKindOfClass:[KMContentView class]])
    {
        [scrollView setContentOffset:CGPointMake(0, -_navigationBarHeight) animated:YES];
        
        id viewController = self.viewControllers[self.pageView.currentIndex];

        if ([viewController isKindOfClass:[UITableViewController class]])
        {
            [[(UITableViewController*)viewController tableView] setContentOffset:CGPointZero animated:YES];
        }
        else if ([viewController isKindOfClass:[UICollectionViewController class]])
        {
            [[(UICollectionViewController*)viewController collectionView] setContentOffset:CGPointZero animated:YES];
        }

        return NO;
    }
    return YES;
}

#pragma mark - navigationBar

- (void)setNavigationBarItemsAlpha:(CGFloat)barItemsAlpha
{
    for (UIView *view in self.navigationBar.subviews)
    {
        bool isBackgroundView = (view == self.navigationBar.subviews.firstObject);
        bool isViewHidden = view.hidden || view.alpha < FLT_EPSILON;
        
        if (!isBackgroundView && !isViewHidden)
        {
            view.alpha = MAX(barItemsAlpha, FLT_EPSILON);
        }
    }
}

#pragma mark - KMScrollView datasource

- (CGFloat)minimumTopOffsetInContentView:(KMContentView *)scrollView
{
    return _minimumTopOffset;
}

#pragma mark - KMPagerView datasource

- (NSInteger)countInPagerView:(KMPageView *)pageView
{
    return [self.viewControllers count];
}

- (UIViewController*)pageView:(KMPageView*)pageView viewControllerForPageAtIndex:(NSInteger)index
{
    if ((index >= 0) && (index < [self.viewControllers count]))
    {
        return self.viewControllers[index];
    }
    return nil;
}

#pragma mark - KMPagerView delegate

- (void)pageViewCurrentIndexDidChange:(KMPageView *)pagerView
{
    if ([self.delegate respondsToSelector:@selector(segmentedPagerCurrentIndexDidChange:)])
    {
        [self.delegate segmentedPagerCurrentIndexDidChange:self];
    }
}

#pragma mark - SETTERS

- (void)setSegmentedBar:(UIView *)segmentedBar
{
    if (_segmentedBar != segmentedBar)
    {
        [_segmentedBar removeFromSuperview];

        _segmentedBar = nil;
        _segmentedBar = segmentedBar;

        [self addSubview:_segmentedBar];
    }
}

- (void)setCurrentIndex:(NSInteger)currentIndex
{
    [self.pageView setCurrentIndex:currentIndex animated:NO];
}

- (void)setCurrentIndex:(NSInteger)currentIndex animated:(BOOL)animated
{
    [self.pageView setCurrentIndex:currentIndex animated:animated];
}

#pragma mark - GETTERS

- (UIEdgeInsets)contentInset
{
    UIEdgeInsets inset = UIEdgeInsetsZero;
    
    if (self.navigationBar)
    {
        inset = UIEdgeInsetsMake(_navigationBarHeight, 0, 0, 0);
    }
    else
    {
        inset = UIEdgeInsetsZero;
    }
    
    return inset;
}

- (KMPageView *)pageView
{
    if (!_pageView)
    {
        _pageView = [[KMPageView alloc] init];
        _pageView.delegate = self;
        _pageView.dataSource = self;
    }
    return _pageView;
}

- (KMContentView *)contentView
{
    if (!_contentView)
    {
        _contentView = [[KMContentView alloc] init];
        _contentView.dataSource = self;
        _contentView.delegate = self;
        
        [self reloadScrollViewContentInset];
        
        [self insertSubview:_contentView atIndex:0];
        [_contentView addSubview:self.pageView];
    }
    return _contentView;
}

- (NSInteger)currentIndex
{
    return self.pageView.currentIndex;
}

- (id)currentViewController
{
    id viewController = nil;
    @try
    {
        viewController = self.viewControllers[self.pageView.currentIndex];
    }
    @catch (NSException *exception)
    {
        
    }
    return viewController;
}

#pragma mark - SETTERS

- (void)setNavigationBarHeight:(CGFloat)navigationBarHeight
{
    if (_navigationBarHeight != navigationBarHeight)
    {
        _navigationBarHeight = navigationBarHeight;

        [self layoutIfNeeded];
        [self setNeedsLayout];
    }
}

- (void)setNavigationBar:(UINavigationBar *)navigationBar
{
    if (_navigationBar != navigationBar)
    {
        [_navigationBar removeFromSuperview];
        _navigationBar = navigationBar;
        _navigationBar.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
                                           UIViewAutoresizingFlexibleRightMargin |
                                           UIViewAutoresizingFlexibleTopMargin |
                                           UIViewAutoresizingFlexibleBottomMargin);

        [self reloadScrollViewContentInset];

        [self addSubview:_navigationBar];
    }
}

@end
