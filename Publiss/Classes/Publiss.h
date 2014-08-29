//
//  Publiss.h
//  Publiss
//
//  Created by Daniel Griesser on 26.08.14.
//  Copyright (c) 2014 Publiss GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Publiss : NSObject

@property (assign, nonatomic) BOOL alwaysUseMainBundleForLocalization;

@property (strong, nonatomic) NSString *googleAnalyticsTrackingCode;
@property (strong, nonatomic) UIColor *primaryColor;
@property (strong, nonatomic) UIColor *fontColor;

+ (Publiss *)staticInstance;
- (NSBundle *)bundle;
- (void)setupWithLicenseKey:(const char *)licenseKey;

@end
