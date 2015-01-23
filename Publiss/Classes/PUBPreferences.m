//
//  PUBPreferences.m
//  Publiss
//
//  Created by Denis Andrasec on 23.01.15.
//  Copyright (c) 2015 Publiss GmbH. All rights reserved.
//

#import "PUBPreferences.h"
#import "Lockbox.h"

static NSString *PUBDeviceIdentifier = @"PUBDeviceIdentifier";
static NSString *PUBPushTokenKey = @"PUBPushTokenKey";

@implementation PUBPreferences

+ (void)setPushToken:(NSString *)pushToken {
    [[NSUserDefaults standardUserDefaults] setObject:pushToken forKey:PUBPushTokenKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString *)pushToken {
    return [NSUserDefaults.standardUserDefaults stringForKey:PUBPushTokenKey];
}

+ (NSString *)deviceIdentifier {
    NSString *persistedDeviceIdentifier = [Lockbox stringForKey:PUBDeviceIdentifier];
    
    if (persistedDeviceIdentifier.length == 0) {
        NSString *createdDeviceIdentifier = [self.class createDeviceIdentifier];
        
        if ([Lockbox setString:createdDeviceIdentifier forKey:PUBDeviceIdentifier]) {
            persistedDeviceIdentifier = createdDeviceIdentifier;
        }
    }
    
    return persistedDeviceIdentifier.lowercaseString;
}

// Helper

+ (NSString *)createDeviceIdentifier {
    return [[NSUUID UUID] UUIDString].lowercaseString;
}

@end
