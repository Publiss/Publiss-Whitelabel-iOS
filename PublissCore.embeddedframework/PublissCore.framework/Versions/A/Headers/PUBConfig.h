//
//  PUBConfig.h
//  Publiss
//
//  Copyright (c) 2014 Publiss GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface PUBConfig : NSObject

+ (PUBConfig *)sharedConfig;

@property (nonatomic, strong) NSString *authToken;
@property (nonatomic, strong) NSString *appToken;
@property (nonatomic, strong) NSString *appSecret;
@property (nonatomic, strong) NSString *googleAnalyticsTrackingCode;
@property (nonatomic, strong) NSNumber *pageTrackTime;
@property (nonatomic, strong) NSURL *webserviceBaseURL;
@property (nonatomic, assign) BOOL inAppPurchaseActive;

@property (nonatomic, strong) UIColor *primaryColor;
@property (nonatomic, strong) UIColor *secondaryColor;
@property (nonatomic, strong) UIColor *kioskBackgroundColor;
@end
