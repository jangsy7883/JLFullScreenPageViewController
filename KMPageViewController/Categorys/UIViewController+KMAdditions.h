//
//  UIViewController+KMAdditions.h
//  KMPageController
//
//  Created by Jangsy7883 on 2016. 2. 29..
//  Copyright © 2016년 Dalkomm. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (KMAdditions)

@property (nonatomic, readonly) UIScrollView *contentScrollView;

- (void)addToParentViewController:(UIViewController *)parentViewController withView:(UIView *)view;

@end

@interface UIView (MSSAutoLayout)

@property (nonatomic, readonly) UIViewController *superViewController;

- (void)addExpandingSubview:(UIView *)subview;

- (void)addExpandingSubview:(UIView *)subview edgeInsets:(UIEdgeInsets)insets;

- (void)addPinnedToTopAndSidesSubview:(UIView *)subview withHeight:(CGFloat)height;

@end

