//
//  PUBConfig.h
//  Publiss
//
//  Copyright (c) 2014 Publiss GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const PUBStatisticsUserDefaultsKey;
extern NSString *const PUBConfigDefaultWebserviceBaseURL;
extern NSString *const PUBConfigDefaultAppToken;
extern NSString *const PUBConfigDefaultAppSecret;

@interface PUBConfig : NSObject


+ (PUBConfig *)sharedConfig;

- (NSString *)appToken;
- (NSString *)appSecret;
- (NSString *)GATrackingCode;
- (NSNumber *)pageTrackTime;
- (NSURL *)webserviceBaseURL;

@end
