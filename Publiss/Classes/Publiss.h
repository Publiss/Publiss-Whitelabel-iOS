//
//  Publiss.h
//  Publiss
//
//  Created by Daniel Griesser on 26.08.14.
//  Copyright (c) 2014 Publiss GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>


extern NSString *PUBLocalize(NSString *stringToken) NS_FORMAT_ARGUMENT(1);
extern void PUBSetLocalizationBlock(NSString *(^localizationBlock)(NSString *stringToLocalize));
extern void PUBSetLocalizationDictionary(NSDictionary *localizationDict);

@interface Publiss : NSObject

@property (assign, nonatomic) BOOL alwaysUseMainBundleForLocalization;

@property (strong, nonatomic) NSString *googleAnalyticsTrackingCode;
@property (strong, nonatomic) UIColor *primaryColor;
@property (strong, nonatomic) UIColor *fontColor;

+ (Publiss *)staticInstance;
- (void)setupWithLicenseKey:(const char *)licenseKey;

@end
