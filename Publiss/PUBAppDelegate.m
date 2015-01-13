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

@implementation PUBAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    PUBConfig.sharedConfig.appToken = @"1d3ae766-0206-4eb7-90e1-f2e2917a4635";
    PUBConfig.sharedConfig.appSecret = @"9fc4153103bd73cbe36c88738dc9e8bb";
    [Publiss.staticInstance setupWithLicenseKey:nil];
    
    // Uncomment this line to use the language tag feature.
    //PUBConfig.sharedConfig.preferredLanguage = [[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode];

    // Uncomment this line to add user login to menu
    // PUBAuthentication.sharedInstance.loginEnabled = YES;
    [PUBAuthentication.sharedInstance configureCommunications];
    
    self.window.tintColor = PUBConfig.sharedConfig.primaryColor;
    [UINavigationBar.appearance setTintColor:PUBConfig.sharedConfig.secondaryColor];
    [UINavigationBar.appearance setBarTintColor:self.window.tintColor];
    [UINavigationBar.appearance setTitleTextAttributes:@{NSForegroundColorAttributeName:PUBConfig.sharedConfig.secondaryColor}];
    
    self.window.rootViewController = (UIViewController *)PUBMainViewController.mainViewController;
    [self.window makeKeyAndVisible];
    
    return YES;
}

@end
