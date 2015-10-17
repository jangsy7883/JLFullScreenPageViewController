//
//  KMSegmented.h
//  KMSegmentedPager
//
//  Created by IM049 on 2015. 9. 6..
//  Copyright (c) 2015년 Jangsy7883. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KMSegmentedBar;

@protocol KMSegmentedViewDelegate <NSObject>

- (void)segmentedBar:(KMSegmentedBar*)segmentedView didSelectIndex:(NSInteger)index;

@end

@protocol KMSegmentedBarDataSource <NSObject>

- (NSArray*)titlesInSegmentedBar:(KMSegmentedBar*)segmentedView;

@end

@interface KMSegmentedBar : UIView

@property (nonatomic, readonly) UIView *segmentedBar;

@property (nonatomic, assign) CGSize itemSize;
@property (nonatomic, assign) CGFloat segmentedBarHeight;

@property (nonatomic, strong) UIFont *font;
@property (nonatomic, strong) UIColor *titleColor;
@property (nonatomic, strong) UIColor *highlightedTitleColor;
@property (nonatomic, strong) UIImage *shadowImage;

@property (nonatomic, weak) id<KMSegmentedBarDataSource> dataSource;
@property (nonatomic, weak) id<KMSegmentedViewDelegate> delegate;

- (void)reloadData;
- (void)scrollDidContentOffset:(CGPoint)contentOffset;

@end
