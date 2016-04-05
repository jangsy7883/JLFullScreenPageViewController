//
//  KMPagerController.h
//  KMPageController
//
//  Created by Jangsy7883 on 2015. 9. 4..
//  Copyright © 2015년 Dalkomm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KMPageView.h"
#import "KMSegmentedBar.h"

typedef NS_ENUM(NSInteger, KMFullScreenMode)
{
    KMFullScreenModeAutomatic = 0,
    KMFullScreenModeScrolling,
};

@interface KMPageViewController : UIViewController<KMPageViewDataSource,KMPageViewDelegate>

@property (nonatomic, strong, readonly) UINavigationBar *navigationBar;
@property (nonatomic, strong, readonly) KMPageView *pageView;
@property (nonatomic, strong) UIView *headerView;

@property (nonatomic, assign) KMFullScreenMode fullScreenMode;
@property (nonatomic, assign, getter = isNavigationBarHidden) BOOL navigationBarHidden;

@end

@interface UIViewController (KMPageViewController)

@property (nonatomic, weak, readonly) KMPageViewController *pageViewController;

@end