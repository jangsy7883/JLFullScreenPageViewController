//
//  KMPagerView.h
//  JLFullScreenPageViewController
//
//  Created by Jangsy7883 on 2015. 9. 4..
//  Copyright © 2015년 Dalkomm. All rights reserved.
//

#import "JLPageViewController.h"

@class JLContentPageViewController;

@protocol JLContentPageViewControllerDataSource <JLPageViewControllerDataSource>

@required

- (NSArray<UIViewController*> *)viewControllersForPageViewController:(JLPageViewController *)pageViewController;

@end

@interface JLContentPageViewController : JLPageViewController

@property (nonatomic, readonly) NSArray *viewControllers;
@property (nonatomic, weak) id<JLContentPageViewControllerDataSource> dataSource;

@end
