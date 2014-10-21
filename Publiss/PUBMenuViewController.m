//
//  PUBMenuViewController.m
//  Publiss
//
//  Created by Daniel Griesser on 21.10.14.
//  Copyright (c) 2014 Publiss GmbH. All rights reserved.
//

#import "PUBMenuViewController.h"

@interface PUBMenuViewController ()

@property (strong, nonatomic) IBOutlet UITableView *tableView;

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
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
