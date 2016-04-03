//
//  KMPagerView.h
//  KMSegmentedPager
//
//  Created by Jangsy7883 on 2015. 9. 4..
//  Copyright © 2015년 Dalkomm. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KMPageView;

@protocol KMPageViewDelegate <UIScrollViewDelegate>

@optional
- (void)pageViewDidScroll:(KMPageView *)pageView;
- (void)pageViewCurrentIndexDidChange:(KMPageView *)pagerView;

@end

@protocol KMPageViewDataSource <NSObject>

- (NSInteger)numberOfPageInPageView:(KMPageView*)pageView;
- (UIViewController*)pageView:(KMPageView*)pageView viewControllerForPageAtIndex:(NSInteger)index;

@end

@interface KMPageView : UIScrollView

@property (nonatomic, assign) NSUInteger currentIndex;
@property (nonatomic, assign, getter = isScrollPagingEnabled) BOOL scrollPagingEnabled;

@property (nonatomic, readonly) NSArray *visibleViewContollers;

@property (nonatomic, weak) id<KMPageViewDelegate>delegate;
@property (nonatomic, weak) id<KMPageViewDataSource>dataSource;

- (void)reloadData;

- (void)setCurrentIndex:(NSUInteger)currentIndex animated:(BOOL)animated;

@end
