//
//  TableViewController.m
//  KMSegmentedPagerDemo
//
//  Created by Jangsy7883 on 2015. 10. 17..
//  Copyright © 2015년 Dalkomm. All rights reserved.
//

#import "TableViewController.h"
#import "KMPageViewController.h"

@interface TableViewController ()

@end

@implementation TableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.scrollsToTop = YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@ : %ld",self.title,(long)indexPath.row];
    
    return cell;
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [NSString stringWithFormat:@"section %ld",(long)section];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    UIViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Table1"];
//    viewController.title = @"detail";
//    
//    [self.navigationController pushViewController:viewController animated:self];
    
}

@end
