//
//  KMPagerController.m
//  KMPageController
//
//  Created by IM049 on 2015. 9. 4..
//  Copyright (c) 2015년 Jangsy7883. All rights reserved.
//

#import "KMPageViewController.h"

@interface KMPageViewController ()

@property (nonatomic, strong) KMPageView *pageView;

@end

@implementation KMPageViewController

#pragma mark - view lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    CGRect viewRect = self.view.bounds;

    //SEGMENTED
    self.headerView.frame = CGRectMake(0,
                                       self.topLayoutGuide.length,
                                       CGRectGetWidth(viewRect),
                                       CGRectGetHeight(self.headerView.frame));
        
    //PAGE
    CGFloat pageY = self.headerView == nil ? self.topLayoutGuide.length : CGRectGetMaxY(self.headerView.frame);
    self.pageView.frame = CGRectMake(0,
                                     pageY,
                                     CGRectGetWidth(viewRect),
                                     CGRectGetHeight(viewRect) - pageY);
}

#pragma mark - SETTERS

- (void)setHeaderView:(UIView *)headerView
{
    if (_headerView != headerView)
    {
        [_headerView removeFromSuperview];

        _headerView = nil;
        _headerView = headerView;

        [self.view addSubview:_headerView];
    }
}

#pragma mark - GETTERS

- (KMPageView*)pageView
{
    if (_pageView == nil)
    {
        _pageView = [[KMPageView alloc] init];
        [self.view insertSubview:_pageView atIndex:0];
    }
    return _pageView;
}


@end
