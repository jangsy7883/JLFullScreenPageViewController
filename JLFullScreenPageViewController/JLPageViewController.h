//
//  KMPagerView.h
//  JLFullScreenPageViewController
//
//  Created by Jangsy7883 on 2015. 9. 4..
//  Copyright © 2015년 Dalkomm. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JLPageViewController;

@protocol JLPageViewControllerDelegate <NSObject>

@optional

- (void)pageViewController:(JLPageViewController*)viewController didScrollToCurrentPosition:(CGFloat)currentPosition;
- (void)pageViewController:(JLPageViewController*)viewController didChangeToCurrentIndex:(NSUInteger)currentIndex fromIndex:(NSUInteger)fromIndex;

@end

@protocol JLPageViewControllerDataSource <NSObject>

- (NSArray *)viewControllersForPageViewController:(JLPageViewController *)viewController;
- (NSInteger)defaultPageIndexForPageViewController:(JLPageViewController *)pageViewController;

@end

@interface JLPageViewController : UIViewController

@property (nonatomic, assign) NSUInteger currentIndex;

@property (nonatomic, assign, getter = isScrollPagingEnabled) BOOL scrollPagingEnabled;

@property (nonatomic, readonly) UIViewController* currentViewController;
@property (nonatomic, readonly) NSArray *viewControllers;
@property (nonatomic, readonly) NSInteger numberOfPage;

@property (nonatomic, weak) id<JLPageViewControllerDelegate>delegate;
@property (nonatomic, weak) id<JLPageViewControllerDataSource>dataSource;

- (void)reloadData;

- (void)setCurrentIndex:(NSUInteger)currentIndex animated:(BOOL)animated;

@end
