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

- (void)segmentedBar:(KMSegmentedBar*)segmentedView didSelectIndex:(NSInteger)index;

@end

@protocol KMSegmentedBarDataSource <NSObject>

- (NSArray*)titlesInSegmentedBar:(KMSegmentedBar*)segmentedView;

@end

@interface KMSegmentedBar : UIView

/**
 * barItmeSizFit이 YES일 경우 버튼 하나의 크기가 텍스트 길이로 맞춰진다.
 * barItmeSizFit이 NO일 경우 뷰의 크기에 맞춰 균등하게 정해진다.
 * @method  barItmeSizFit
 * @date 2015.11.12
 * @author Jangsy7883,
 */
@property (nonatomic, assign, getter=isBarItmeSizFit) BOOL barItmeSizFit;

//Separator
@property (nonatomic, assign) CGFloat separatorHeight;
@property (nonatomic, strong) UIColor *separatorColor;

@property (nonatomic, assign) CGFloat fitMargin;

@property (nonatomic, strong) UIFont *font;
@property (nonatomic, strong) UIColor *titleColor;
@property (nonatomic, strong) UIColor *highlightedTitleColor;
@property (nonatomic, strong) UIImage *shadowImage;

@property (nonatomic, weak) id<KMSegmentedBarDataSource> dataSource;
@property (nonatomic, weak) id<KMSegmentedBarDelegate> delegate;

- (void)reloadData;
- (void)scrollDidContentOffset:(CGFloat)contentOffset;

@end
