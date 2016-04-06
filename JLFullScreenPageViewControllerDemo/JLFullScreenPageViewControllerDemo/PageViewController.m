//
//  PageViewController.m
//  JLFullScreenPageViewControllerDemo
//
//  Created by Jangsy7883 on 2015. 10. 17..
//  Copyright © 2015년 Dalkomm. All rights reserved.
//

#import "PageViewController.h"
#import "TableViewController.h"

@interface PageViewController ()<KMSegmentedBarDataSource,JLSegmentedBarDelegate>

@property (nonatomic,strong) JLSegmentedBar *segmentedBar;

@property (nonatomic,strong) TableViewController *table1;
@property (nonatomic,strong) TableViewController *table2;
@property (nonatomic,strong) TableViewController *table3;

@end

@implementation PageViewController

#pragma mark - memory

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - viwe lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"KMPageView";
    [titleLabel sizeToFit];
    self.navigationBar.topItem.titleView = titleLabel;
    self.navigationBar.topItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                                  target:self
                                                                                                  action:@selector(pressedCancel:)];
    
    self.segmentedBar = [[JLSegmentedBar alloc] init];
    self.segmentedBar.backgroundColor = [UIColor darkGrayColor];
    self.segmentedBar.barStyle = JLSegmentedBarStyleEqualSegment;
    self.segmentedBar.titleColor = [UIColor blackColor];
    self.segmentedBar.highlightedTitleColor = [UIColor whiteColor];
    self.segmentedBar.separatorColor = [UIColor whiteColor];
    self.segmentedBar.delegate = self;
    self.segmentedBar.dataSource = self;
    self.segmentedBar.frame = CGRectMake(0,
                                         0,
                                         CGRectGetWidth(self.view.bounds),
                                         40);
    [self.segmentedBar reloadData];
    self.headerView = self.segmentedBar;
    
    self.pageViewController.scrollPagingEnabled = YES;
    [self.pageViewController reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

#pragma mark - event

- (void)pressedCancel:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - KMPagerView datasource

- (NSArray *)viewControllersForPageViewController:(JLPageViewController *)viewController
{
    NSMutableArray *viewControllers = [NSMutableArray array];
    
    if (self.table1 == nil)
    {
        self.table1 = [self.storyboard instantiateViewControllerWithIdentifier:@"Table1"];
        self.table1.tableView.scrollsToTop = YES;
        self.table1.tableView.tag = 0;
        self.table1.title = @"Table1";
    }
    
    if (self.table2 == nil)
    {
        self.table2 = [self.storyboard instantiateViewControllerWithIdentifier:@"Table2"];
        self.table2.title = @"Table2";
        self.table2.tableView.tag = 1;
    }
    
    if (self.table3 == nil)
    {
        self.table3 = [self.storyboard instantiateViewControllerWithIdentifier:@"Table3"];
        self.table3.title = @"Table3";
        self.table3.tableView.tag = 2;
    }
    
    [viewControllers addObject:self.table1];
    [viewControllers addObject:self.table2];
    [viewControllers addObject:self.table3];
    
    return viewControllers;
}

#pragma mark - KMPagerView delegate

- (void)pageViewController:(JLPageViewController*)viewController didScrollToCurrentPosition:(CGFloat)currentPosition
{
    [self.segmentedBar scrollDidContentOffset:currentPosition];
}

-  (void)pageViewController:(JLPageViewController*)viewController didScrollToCurrentIndex:(NSUInteger)currentIndex
{
    
}

#pragma mark - KMSegmentedView delegate

- (void)segmentedBar:(JLSegmentedBar *)segmentedBar didSelectIndex:(NSInteger)index
{
    [self.pageViewController setCurrentIndex:index animated:YES];
}

#pragma mark - KMSegmentedView dataSource

- (NSArray*)titlesInSegmentedBar:(JLSegmentedBar *)segmentedBar
{
    return @[
             @"first",@"second",@"third"
             ];
}

@end
