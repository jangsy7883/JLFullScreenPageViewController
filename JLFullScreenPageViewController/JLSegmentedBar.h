//
//  JLSegmentedBar.h
//  JLFullScreenPageViewController
//
//  Created by Jangsy7883 on 2015. 9. 6..
//  Copyright © 2015년 Dalkomm. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JLSegmentedBar;

@protocol JLSegmentedBarDelegate <NSObject>

@optional

- (void)segmentedBar:(JLSegmentedBar*)segmentedView didSelectIndex:(NSInteger)index;

@end

@protocol JLSegmentedBarDataSource <NSObject>

- (NSArray*)titlesInSegmentedBar:(JLSegmentedBar*)segmentedView;

@end

typedef NS_ENUM(NSInteger, JLSegmentedBarStyle)
{
    JLSegmentedBarStyleRightFit = 0,
    JLSegmentedBarStyleEqualSegment,
    JLSegmentedBarStyleEqualMargin,
};

@interface JLSegmentedBar : UIView

@property (nonatomic, assign) JLSegmentedBarStyle barStyle;

//Separator
@property (nonatomic, assign) CGFloat separatorHeight;
@property (nonatomic, strong) UIColor *separatorColor;

@property (nonatomic, assign) UIEdgeInsets contentInsets;
@property (nonatomic, assign) CGFloat itemMergin;

@property (nonatomic, strong) UIFont *font;
@property (nonatomic, strong) UIColor *titleColor;
@property (nonatomic, strong) UIColor *highlightedTitleColor;
@property (nonatomic, strong) UIImage *shadowImage;

@property (nonatomic, weak) id<JLSegmentedBarDataSource> dataSource;
@property (nonatomic, weak) id<JLSegmentedBarDelegate> delegate;

@property (nonatomic, assign) NSInteger selectedIndex;

- (void)reloadData;
- (void)scrollDidContentOffset:(CGFloat)contentOffset;

- (void)setSelectedIndex:(NSInteger)selectedIndex animated:(BOOL)animated;

@end
