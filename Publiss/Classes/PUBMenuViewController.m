//
//  PUBMenuViewController.m
//  Publiss
//
//  Created by Daniel Griesser on 21.10.14.
//  Copyright (c) 2014 Publiss GmbH. All rights reserved.
//

#import "PUBMenuViewController.h"
#import "PUBMenuTableViewCell.h"
#import "PUBMenuItem.h"
#import "PUBMenuItemManager.h"
#import "REFrostedViewController.h"

@interface PUBMenuViewController ()

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) CAGradientLayer *maskLayer;

@end

@implementation PUBMenuViewController

+ (PUBMenuViewController *)menuViewController {
    return [PUBMenuViewController menuViewControllerWithStoryboardName:@"PUBMenu"];
}

+ (PUBMenuViewController *)menuViewControllerWithStoryboardName:(NSString *)storyboard {
    return [[UIStoryboard storyboardWithName:storyboard bundle:nil] instantiateInitialViewController];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

- (void)viewDidLoad {
    [super viewDidLoad];
  
    self.tableView.opaque = NO;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.contentInset = UIEdgeInsetsMake(14, 0, 0, 0);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (!self.maskLayer) {
        self.maskLayer = [CAGradientLayer layer];
        CGColorRef outerColor = [UIColor colorWithWhite:1.0 alpha:0.0].CGColor;
        CGColorRef innerColor = [UIColor colorWithWhite:1.0 alpha:1.0].CGColor;
        self.maskLayer.colors = @[(__bridge id)outerColor, (__bridge id)innerColor];
        self.maskLayer.anchorPoint = CGPointZero;
        self.tableView.layer.mask = self.maskLayer;
    }
    [self scrollViewDidScroll:self.tableView];
}

- (void)viewWillLayoutSubviews {
    self.maskLayer.bounds = CGRectMake(0, 0,
                                       self.view.frame.size.width,
                                       self.view.frame.size.height);
    self.maskLayer.locations = @[@(0.0),@(100 * 18 / self.view.frame.size.height / 100)];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    self.maskLayer.position = CGPointMake(0, scrollView.contentOffset.y);
    [CATransaction commit];
}


#pragma mark UITableView Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex {
    return PUBMenuItemManager.sharedInstance.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"menu";
    
    PUBMenuTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[PUBMenuTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.backgroundColor = [UIColor clearColor];
    
    PUBMenuItem *menuItem = [self menuItemForIndexPath:indexPath];
    cell.titleLabel.text = menuItem.title;
    cell.icon.image = menuItem.icon;

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.frostedViewController hideMenuViewController];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    PUBMenuItem *menuItem = [self menuItemForIndexPath:indexPath];
    if (menuItem.actionBlock) {
        menuItem.actionBlock();
    }
}

- (PUBMenuItem *)menuItemForIndexPath:(NSIndexPath *)indexPath {
    return [PUBMenuItemManager.sharedInstance.items objectAtIndex:indexPath.row];
}

@end
