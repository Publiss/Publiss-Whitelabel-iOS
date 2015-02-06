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
#import "PUBCommunication+Push.h"
#import "PUBConfig.h"


@implementation PUBAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    application.applicationIconBadgeNumber = 0;
    
    PUBConfig.sharedConfig.appToken = @"1d3ae766-0206-4eb7-90e1-f2e2917a4635";
    PUBConfig.sharedConfig.appSecret = @"9fc4153103bd73cbe36c88738dc9e8bb";
    
    [Publiss.staticInstance setupWithLicenseKey:"T/b4cf+SB2t6JcWU/Izbkzkt8j70K2Zc9S5ubSdyI6cuJm1Q0tBv8eQz7DpN"
     "J0/RAblrGUgI2T7mHc3vpqPHEAjd8XG9J3naWNgbrhQvaMhUmv7RBVI4tvAf"
     "/S2PJDvUyrx63cz/wNIEnVFxQTGfZvqFNaKMFLQMEUqGbRVzRZHE553GATeX"
     "77BnVcMOoQSPgEV6jrSLkvuYEa0XNDG6ZE/xNkaRViwW70Mmsa71YY9gKjz0"
     "T6fbD/hjcZtzNBc701VGYBSmA6AkymVMShF3lPgEXyTdbRq6g38tNDn+Tls6"
     "6yAWCMOw1cxnCHtX05E/yEbHC8JlsLiE7R5T04PeMwVLvjWdBJ0HTmUQfInj"
     "hIz5VPt36/rzM3bbS0bIZ4T6R2APaWugHU6YqHGDP3/PYdaSa+kJ8zudC0qj"
     "wB8b3JEbO8KSFdcArmZFLe2/A40Di7jQjuf9R/i4fLMF22/KQhFx6qvrntUQ"
     "eKjpcLFhULk+m5OJ5Ap6yAJ6gy0DaCEouw13MS9Tl+GfP+6kzg5GMw=="];
    
    // Uncomment this line to use the language tag feature.
    //PUBConfig.sharedConfig.preferredLanguage = [[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode];

    PUBConfig.sharedConfig.showLabelsBelowIssuesInKiosk = YES;
    
    // Uncomment this line to add user login to menu
    PUBAuthentication.sharedInstance.loginEnabled = YES;
    [PUBAuthentication.sharedInstance configureCommunications];
    
    self.window.tintColor = PUBConfig.sharedConfig.primaryColor;
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
    [PUBCommunication.sharedInstance sendPushTokenToServer];
    PUBLog(@"%@", deviceToken);
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    PUBLog(@"%@", error);
    [PUBCommunication.sharedInstance sendPushTokenToServer];
}


@end
