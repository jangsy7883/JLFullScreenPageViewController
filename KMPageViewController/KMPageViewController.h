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

@property (nonatomic, readonly) KMPageView *pageView;
@property (nonatomic, strong) UIView *headerView;

@end

