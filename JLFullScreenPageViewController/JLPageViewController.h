//
//  KMPagerView.h
//  JLFullScreenPageViewController
//
//  Created by Jangsy7883 on 2015. 9. 4..
//  Copyright © 2015년 Dalkomm. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JLPageViewController;

@protocol KMPageViewDelegate <NSObject>

@optional

- (void)pageViewController:(JLPageViewController*)viewController didScrollToCurrentPosition:(CGFloat)currentPosition;
- (void)pageViewController:(JLPageViewController*)viewController didScrollToCurrentIndex:(NSUInteger)currentIndex;

@end

@protocol KMPageViewDataSource <NSObject>

- (NSArray *)viewControllersForPageViewController:(JLPageViewController *)viewController;

@end

@interface JLPageViewController : UIViewController

@property (nonatomic, assign) NSUInteger currentIndex;

@property (nonatomic, assign, getter = isScrollPagingEnabled) BOOL scrollPagingEnabled;

@property (nonatomic, readonly) UIViewController* currentViewController;
@property (nonatomic, readonly) NSArray *viewControllers;
@property (nonatomic, readonly) NSInteger numberOfPage;

@property (nonatomic, weak) id<KMPageViewDelegate>delegate;
@property (nonatomic, weak) id<KMPageViewDataSource>dataSource;

- (void)reloadData;

- (void)setCurrentIndex:(NSUInteger)currentIndex animated:(BOOL)animated;

@end
