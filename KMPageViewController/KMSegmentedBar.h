//
//  KMSegmented.h
//  KMSegmentedPager
//
//  Created by IM049 on 2015. 9. 6..
//  Copyright (c) 2015년 Jangsy7883. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KMSegmentedBar;

@protocol KMSegmentedBarDelegate <NSObject>

- (void)segmentedBar:(KMSegmentedBar*)segmentedBar didSelectIndex:(NSInteger)index;

@end

@protocol KMSegmentedBarDataSource <NSObject>

- (NSArray*)titlesInSegmentedBar:(KMSegmentedBar*)segmentedBar;

@end

@interface KMSegmentedBar : UIView

@property (nonatomic, assign) CGSize itemSize;
@property (nonatomic, assign) CGFloat lineHeight;
@property (nonatomic, strong) UIColor *lineColor;

@property (nonatomic, strong) UIFont *font;
@property (nonatomic, strong) UIColor *titleColor;
@property (nonatomic, strong) UIColor *highlightedTitleColor;
@property (nonatomic, strong) UIImage *shadowImage;

@property (nonatomic, weak) id<KMSegmentedBarDataSource> dataSource;
@property (nonatomic, weak) id<KMSegmentedBarDelegate> delegate;

- (void)reloadData;
- (void)scrollDidContentOffset:(CGPoint)contentOffset;

@end
