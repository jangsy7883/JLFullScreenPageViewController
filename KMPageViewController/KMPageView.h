//
//  KMPagerView.h
//  KMSegmentedPager
//
//  Created by IM049 on 2015. 9. 4..
//  Copyright (c) 2015년 Jangsy7883. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KMPageView;

@protocol KMPageViewDelegate <UIScrollViewDelegate>

- (void)pageViewCurrentIndexDidChange:(KMPageView *)pagerView;

@end

@protocol KMPageViewDataSource <NSObject>

- (NSInteger)countInPagerView:(KMPageView*)pageView;
- (UIViewController*)pageView:(KMPageView*)pageView viewControllerForPageAtIndex:(NSInteger)index;

@end

@interface KMPageView : UIScrollView

@property (nonatomic, assign) NSUInteger currentIndex;
@property (nonatomic, assign, getter = isScrollPagingEnabled) BOOL scrollPagingEnabled;

@property (nonatomic, weak) id<KMPageViewDelegate>delegate;
@property (nonatomic, weak) id<KMPageViewDataSource>dataSource;

- (void) reloadData;

- (void)setCurrentIndex:(NSUInteger)currentIndex animated:(BOOL)animated;

@end
