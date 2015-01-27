//
//  PUBAppDelegate.m
//  Publiss
//
//  Copyright (c) 2014 Publiss GmbH. All rights reserved.
//

#import "PUBAppDelegate.h"
#import <PublissCore.h>
#import "Publiss.h"
#import "PUBConstants.h"
#import "PUBMainViewController.h"
#import "PUBAuthentication.h"
#import "PUBPreferences.h"
#import "PUBCommunication.h"
#import "PUBConfig.h"

@implementation PUBAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    application.applicationIconBadgeNumber = 0;
    
    PUBConfig.sharedConfig.appToken = @"1d3ae766-0206-4eb7-90e1-f2e2917a4635";
    PUBConfig.sharedConfig.appSecret = @"9fc4153103bd73cbe36c88738dc9e8bb";
    [Publiss.staticInstance setupWithLicenseKey:nil];
    
    // Uncomment this line to use the language tag feature.
    // PUBConfig.sharedConfig.preferredLanguage = [[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode];

    // Uncomment this line to add user login to menu
    // PUBAuthentication.sharedInstance.loginEnabled = YES;
    [PUBAuthentication.sharedInstance configureCommunications];
    
    self.window.tintColor = PUBConfig.sharedConfig.primaryColor;
    
    // Uncomment for dark status bar
    //PUBConfig.sharedConfig.statusBarStyle = UIStatusBarStyleDefault;
    
    [UINavigationBar.appearance setTintColor:PUBConfig.sharedConfig.secondaryColor];
    [UINavigationBar.appearance setBarTintColor:self.window.tintColor];
    [UINavigationBar.appearance setTitleTextAttributes:@{NSForegroundColorAttributeName:PUBConfig.sharedConfig.secondaryColor}];
    
    self.window.rootViewController = (UIViewController *)PUBMainViewController.mainViewController;
    [self.window makeKeyAndVisible];
    
    [self registerForPush];
    
    return YES;
}

- (void)registerForPush {
    if ([UIApplication.sharedApplication respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        [UIApplication.sharedApplication registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [UIApplication.sharedApplication registerForRemoteNotifications];
    } else {
        // iOS 7
        [UIApplication.sharedApplication registerForRemoteNotificationTypes:(UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert)];
    }
}

- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [PUBPreferences validateAndPersistPushToken:deviceToken];
    [self sendPushTokenToServer];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    PUBLog(@"%@", error);
}

- (void)sendPushTokenToServer {
    [[PUBCommunication sharedInstance] sendPushTokenToBackend:[PUBPreferences deviceIdentifier]
                                                    pushToken:[PUBPreferences pushToken]
                                                   deviceType:PUBDeviceTypeIos
                                                     language:[[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode]
                                                   completion:^(id responseObject) {
                                                       PUBLog(@"Successfully send push token.");
                                                   } error:^(NSError *error) {
                                                       PUBLogError(@"Error sending push token. %@", error);
                                                   }];
}

@end
