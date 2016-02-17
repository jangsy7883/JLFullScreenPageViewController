//
//  KMPagerController.h
//  KMPageController
//
//  Created by IM049 on 2015. 9. 4..
//  Copyright (c) 2015년 Jangsy7883. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KMPageView.h"
#import "KMSegmentedBar.h"

@interface KMPageViewController : UIViewController

@property (nonatomic, strong) UINavigationBar *navigationBar;
@property (nonatomic, strong) UIView *headerView;

@property (nonatomic, assign) BOOL autoScrollingNavigationBar;
@property (nonatomic, readonly) KMPageView *pageView;

@end


@interface UIViewController (KMPageViewController)

@property (nonatomic, weak, readonly) KMPageViewController *pageViewController;

@end