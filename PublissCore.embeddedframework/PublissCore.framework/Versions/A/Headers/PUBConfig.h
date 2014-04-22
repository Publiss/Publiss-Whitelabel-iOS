//
//  PUBConfig.h
//  Publiss
//
//  Copyright (c) 2014 Publiss GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString *const PUBStatisticsUserDefaultsKey = @"PUBStatisticsUserDefaultsKey";
static NSString *const PUBConfigDefaultAppToken = @"App Token";
static NSString *const PUBConfigDefaultAppSecret = @"App Secret";
static NSString *const PUBConfigTempAppSecret = @"Temp App Secret";
static NSString *const PUBConfigTempAppToken = @"Temp App Token";

@interface PUBConfig : NSObject


+ (PUBConfig *)sharedConfig;

- (NSString *)appToken;
- (NSString *)appSecret;
- (NSString *)GATrackingCode;
- (NSNumber *)pageTrackTime;
- (NSURL *)webserviceBaseURL;

@end
