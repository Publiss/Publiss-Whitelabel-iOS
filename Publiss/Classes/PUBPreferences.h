//
//  PUBPreferences.h
//  Publiss
//
//  Created by Denis Andrasec on 23.01.15.
//  Copyright (c) 2015 Publiss GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PUBPreferences : NSObject

+ (void)setPushToken:(NSString *)pushToken;
+ (NSString *)pushToken;

+ (NSString *)deviceIdentifier;

@end
