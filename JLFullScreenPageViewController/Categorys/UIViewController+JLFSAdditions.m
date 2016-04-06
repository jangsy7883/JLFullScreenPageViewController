//
//  UIViewController+JLFSAdditions.m
//  JLFullScreenPageViewController
//
//  Created by Jangsy7883 on 2016. 2. 29..
//  Copyright © 2016년 Dalkomm. All rights reserved.
//

#import "UIViewController+JLFSAdditions.h"

@implementation UIViewController (JLFSAdditions)

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

@end


@implementation UIView (JLFSAdditions)

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

@end
