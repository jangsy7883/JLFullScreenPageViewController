//
//  UIViewController+JLFSAdditions.h
//  JLFullScreenPageViewController
//
//  Created by Jangsy7883 on 2016. 2. 29..
//  Copyright © 2016년 Dalkomm. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (JLFSAdditions)

@property (nonatomic, readonly) UIScrollView *contentScrollView;

@end

@interface UIView (JLFSAdditions)

@property (nonatomic, readonly) UIViewController *superViewController;

@end

