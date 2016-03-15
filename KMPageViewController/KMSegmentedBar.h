//
//  KMSegmentedBar.h
//  KMPageController
//
//  Created by Jangsy7883 on 2015. 9. 6..
//  Copyright © 2015년 Dalkomm. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KMSegmentedBar;

@protocol KMSegmentedBarDelegate <NSObject>

@optional

- (void)segmentedBar:(KMSegmentedBar*)segmentedView didSelectIndex:(NSInteger)index;

@end

@protocol KMSegmentedBarDataSource <NSObject>

- (NSArray*)titlesInSegmentedBar:(KMSegmentedBar*)segmentedView;

@end

typedef NS_ENUM(NSInteger, KMSegmentedBarStyle)
{
    KMSegmentedBarStyleRightFit = 0,
    KMSegmentedBarStyleEqualSegment,
    KMSegmentedBarStyleEqualMargin,
};

@interface KMSegmentedBar : UIView

@property (nonatomic, assign) KMSegmentedBarStyle barStyle;

//Separator
@property (nonatomic, assign) CGFloat separatorHeight;
@property (nonatomic, strong) UIColor *separatorColor;

@property (nonatomic, assign) UIEdgeInsets contentInsets;
@property (nonatomic, assign) CGFloat itemMergin;

@property (nonatomic, strong) UIFont *font;
@property (nonatomic, strong) UIColor *titleColor;
@property (nonatomic, strong) UIColor *highlightedTitleColor;
@property (nonatomic, strong) UIImage *shadowImage;

@property (nonatomic, weak) id<KMSegmentedBarDataSource> dataSource;
@property (nonatomic, weak) id<KMSegmentedBarDelegate> delegate;

@property (nonatomic, assign) NSInteger selectedIndex;

- (void)reloadData;
- (void)scrollDidContentOffset:(CGFloat)contentOffset;

- (void)setSelectedIndex:(NSInteger)selectedIndex animated:(BOOL)animated;

@end
