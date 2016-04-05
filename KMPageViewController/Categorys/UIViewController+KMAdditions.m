//
//  UIViewController+KMAdditions.m
//  KMPageController
//
//  Created by Jangsy7883 on 2016. 2. 29..
//  Copyright © 2016년 Dalkomm. All rights reserved.
//

#import "UIViewController+KMAdditions.h"

@implementation UIViewController (KMAdditions)

- (UIScrollView*)contentScrollView
{
    if ([self.view isKindOfClass:[UIScrollView class]])
    {
        return (UIScrollView*)self.view;
    }
    
    for (UIScrollView* scrollView in self.view.subviews)
    {
        if ([scrollView isKindOfClass:[UIScrollView class]])
        {
            return scrollView;
        }
    }
    return nil;
}

- (void)addToParentViewController:(UIViewController *)parentViewController withView:(UIView *)view
{
    if (self.parentViewController)
    {
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
    }
    
    [parentViewController addChildViewController:self];
    [view addExpandingSubview:self.view];
    [self didMoveToParentViewController:parentViewController];
}



@end


@implementation UIView (MSSAutoLayout)


- (UIViewController*)superViewController
{
    for (UIView* next = self; next; next = next.superview)
    {
        UIResponder* nextResponder = [next nextResponder];
        
        if ([nextResponder isKindOfClass:[UIViewController class]])
        {
            return (UIViewController*)nextResponder;
        }
    }
    return nil;
}


- (void)addExpandingSubview:(UIView *)subview {
    [self addExpandingSubview:subview edgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
}

- (void)addExpandingSubview:(UIView *)subview edgeInsets:(UIEdgeInsets)insets {
    [self addView:subview];
    NSDictionary *views = NSDictionaryOfVariableBindings(subview);
    
    NSString *verticalConstraints = [NSString stringWithFormat:@"V:|-%f-[subview]-%f-|", insets.top, insets.bottom];
    NSString *horizontalConstraints = [NSString stringWithFormat:@"H:|-%f-[subview]-%f-|", insets.left, insets.right];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:verticalConstraints
                                                                 options:0
                                                                 metrics:nil
                                                                   views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:horizontalConstraints
                                                                 options:0
                                                                 metrics:nil
                                                                   views:views]];
}

- (void)addPinnedToTopAndSidesSubview:(UIView *)subview withHeight:(CGFloat)height {
    [self addView:subview];
    NSDictionary *views = NSDictionaryOfVariableBindings(subview);
    
    NSDictionary *metrics = @{@"viewHeight":@(height)};
    NSString *verticalConstraints = [NSString stringWithFormat:@"V:|-[subview(viewHeight)]"];
    NSString *horizontalConstraints = [NSString stringWithFormat:@"H:|-[subview]-|"];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:verticalConstraints
                                                                 options:0
                                                                 metrics:metrics
                                                                   views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:horizontalConstraints
                                                                 options:0
                                                                 metrics:nil
                                                                   views:views]];
}

#pragma mark - Internal

- (void)addView:(UIView *)subview {
    if (subview.superview) {
        [subview removeFromSuperview];
    }
    [self addSubview:subview];
    subview.translatesAutoresizingMaskIntoConstraints = NO;
}

@end
