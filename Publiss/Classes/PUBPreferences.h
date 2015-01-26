//
//  PUBPreferences.h
//  Publiss
//
//  Created by Denis Andrasec on 23.01.15.
//  Copyright (c) 2015 Publiss GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PUBPreferences : NSObject

/// After validation this method calls setPushToken:
+ (void)validateAndPersistPushToken:(NSData *)pushToken;
+ (void)setPushToken:(NSString *)pushToken;
+ (NSString *)pushToken;


+ (NSString *)deviceIdentifier;

@end
