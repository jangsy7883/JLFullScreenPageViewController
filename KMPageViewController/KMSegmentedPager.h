//
//  KMSegmentedPager.h
//  KMSegmentedPager
//
//  Created by IM049 on 2015. 9. 4..
//  Copyright (c) 2015년 Jangsy7883. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KMContentView.h"
#import "KMPageView.h"

@protocol KMSegmentedPagerDelegate;

@interface KMSegmentedPager : UIView

@property (nonatomic, readonly) KMPageView *pageView;
@property (nonatomic, readonly) KMContentView *contentView;
@property (nonatomic, strong) UIView *segmentedBar;

@property (nonatomic, strong) UINavigationBar *navigationBar;
@property (nonatomic, assign) CGFloat navigationBarHeight;

@property (nonatomic, readonly) NSArray *viewControllers;
@property (nonatomic, readonly) id currentViewController;

@property (nonatomic, assign) NSInteger currentIndex;

@property (nonatomic, assign) CGFloat minimumTopOffset;

@property (nonatomic, weak) id<KMSegmentedPagerDelegate> delegate;

- (void) reloadDataWithViewControllers:(NSArray*)viewController;

@end

@protocol KMSegmentedPagerDelegate <NSObject>

@optional

- (void)segmentedPager:(KMSegmentedPager*)segmentedPager scrollViewDidScroll:(KMContentView*)scrollView;
- (void)segmentedPager:(KMSegmentedPager*)segmentedPager pageViewDidScroll:(KMPageView*)pagerView;
- (void)segmentedPagerCurrentIndexDidChange:(KMSegmentedPager*)segmentedPager;

@end


