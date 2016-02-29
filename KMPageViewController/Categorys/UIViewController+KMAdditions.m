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

@end