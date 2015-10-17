//
//  KMContentView.h
//  KMSegmentedPager
//
//  Created by IM049 on 2015. 9. 4..
//  Copyright (c) 2015년 Jangsy7883. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KMContentView;

@protocol KMContentViewDataSource <NSObject>

- (CGFloat)minimumTopOffsetInContentView:(KMContentView*)scrollView;

@end

@interface KMContentView : UIScrollView

@property (nonatomic,weak) id<KMContentViewDataSource> dataSource;

- (void)updateContentOffset;
- (void)endDecelerating;

@end
