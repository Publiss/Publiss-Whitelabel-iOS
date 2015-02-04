//
//  PUBUserLoginViewController.h
//  Publiss
//
//  Created by Daniel Griesser on 05.12.14.
//  Copyright (c) 2014 Publiss GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>

#pragma mark - PUBUserLoginDelegate protocol

@class PUBUserLoginViewController;

@protocol PUBUserLoginDelegate <NSObject>

- (BOOL)pubUserShouldLoginWithCredentials:(NSDictionary *)credentials;
- (void)pubUserDidLoginSuccessfully;
- (void)pubUserFailedLoginWithError:(NSString *)message;

@end

#pragma mark - PUBUserLoginViewController interface

@interface PUBUserLoginViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

+ (PUBUserLoginViewController *)userLoginViewController;
+ (PUBUserLoginViewController *)userLoginViewControllerWithDelegate:(id<PUBUserLoginDelegate>)delegate;

@end
