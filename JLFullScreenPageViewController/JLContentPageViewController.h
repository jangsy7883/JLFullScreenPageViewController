//
//  KMPagerView.h
//  JLFullScreenPageViewController
//
//  Created by Jangsy7883 on 2015. 9. 4..
//  Copyright © 2015년 Dalkomm. All rights reserved.
//

#import <JLPageViewController/JLPageViewController.h>

@class JLContentPageViewController;

@protocol JLContentPageViewControllerDataSource <JLPageViewControllerDataSource>

@required

- (NSArray<UIViewController*> *)contentViewControllersForPageViewController:(JLPageViewController *)pageViewController;

@end

@interface JLContentPageViewController : JLPageViewController

@property (nonatomic, readonly) NSArray *contentViewControllers;
@property (nonatomic, weak) id<JLContentPageViewControllerDataSource> dataSource;

@end
