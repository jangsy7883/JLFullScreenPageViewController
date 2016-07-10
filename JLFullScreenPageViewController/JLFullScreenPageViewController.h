//
//  JLFullScreenPageViewController.h
//  JLFullScreenPageViewController
//
//  Created by Jangsy7883 on 2015. 9. 4..
//  Copyright © 2015년 Dalkomm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JLContentPageViewController.h"
#import "JLSegmentedBar.h"

typedef NS_ENUM(NSInteger, JLFullScreenStyle)
{
    JLFullScreenStyleAutomatic = 0,
    JLFullScreenStyleScrolling,
};

@interface JLFullScreenPageViewController : UIViewController

@property (nonatomic, strong, readonly) UINavigationBar *navigationBar;
@property (nonatomic, strong, readonly) JLContentPageViewController *pageViewController;
@property (nonatomic, strong) UIView *headerView;

@property (nonatomic, assign) JLFullScreenStyle fullScreenStyle;

@property (nonatomic, assign) CGFloat contentTopInset;

@property (nonatomic, readonly, getter = isFullScreen) BOOL fullScreen;

@property (nonatomic, assign, getter = isEnableNavigationBar) BOOL enableNavigationBar;
@property (nonatomic, assign, getter = isEnableTabBar) BOOL enableTabBar;

- (void)updateNeedSubviews;

- (void)fullSceenViewControllerWillChangeFullsceenState:(BOOL)isFullScreen
                                               duration:(CGFloat)duration
                                 usingSpringWithDamping:(CGFloat)dampingRatio
                                  initialSpringVelocity:(CGFloat)velocity
                                                options:(UIViewAnimationOptions)options;

- (void)fullSceenViewControllerDidChangeFullsceenState:(BOOL)isFullScreen;

- (void)setFullScreen:(BOOL)isFullScreen animated:(BOOL)animated;

@end

@interface UIViewController (JLFullScreenPageViewController)

@property (nonatomic, weak, readonly) JLFullScreenPageViewController *fullScreenPageViewController;

@end