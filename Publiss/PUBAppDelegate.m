//
//  PUBAppDelegate.m
//  Publiss
//
//  Copyright (c) 2014 Publiss GmbH. All rights reserved.
//

#import "PUBAppDelegate.h"
#import "Publiss.h"
#import "UIColor+PUBDesign.h"

@implementation PUBAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    // Apply global tintColor to icons, fonts in navigationbar etc
    self.window.tintColor = UIColor.fontColor;
    
    [Publiss setupWithLicenseKey:@""];
    
    return YES;
}

- (void)applicationWillTerminate:(UIApplication *)application {

}

- (void)applicationWillResignActive:(UIApplication *)application {
    [NSNotificationCenter.defaultCenter postNotificationName:PUBApplicationWillResignActiveNotification object:nil];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [NSNotificationCenter.defaultCenter postNotificationName:PUBApplicationWillEnterForegroundNotification object:nil];
}

@end
