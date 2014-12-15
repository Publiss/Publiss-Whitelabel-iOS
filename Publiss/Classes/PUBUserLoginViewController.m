//
//  PUBUserLoginViewController.m
//  Publiss
//
//  Created by Daniel Griesser on 05.12.14.
//  Copyright (c) 2014 Publiss GmbH. All rights reserved.
//

#import "PUBUserLoginViewController.h"

@interface PUBUserLoginViewController ()

@end

@implementation PUBUserLoginViewController

+ (PUBUserLoginViewController *)userLoginViewController {
    return [[UIStoryboard storyboardWithName:@"PUBUserLogin" bundle:nil] instantiateInitialViewController];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
