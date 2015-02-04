//
//  PUBCommunication+Push.m
//  Publiss
//
//  Created by Denis Andrasec on 04.02.15.
//  Copyright (c) 2015 Publiss GmbH. All rights reserved.
//

#import "PUBCommunication+Push.h"
#import "PUBAuthentication.h"
#import "PUBPreferences.h"
#import "PUBConstants.h"

@implementation PUBCommunication (Push)

- (void)sendPushTokenToServer {
    NSArray *permissions = PUBAuthentication.sharedInstance.permissionsArray;
    [[PUBCommunication sharedInstance] sendPushTokenToBackend:[PUBPreferences deviceIdentifier]
                                                    pushToken:[PUBPreferences pushToken]
                                                   deviceType:PUBDeviceTypeIos
                                                     language:[[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode]
                                                  permissions:permissions
                                                   completion:^(id responseObject) {
                                                       PUBLog(@"Successfully send push token.");
                                                   } error:^(NSError *error) {
                                                       PUBLogError(@"Error sending push token. %@", error);
                                                   }];
}

@end
