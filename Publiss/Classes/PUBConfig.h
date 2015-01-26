//
//  PUBConfig.h
//  Publiss
//
//  Created by Denis Andrasec on 26.01.15.
//  Copyright (c) 2015 Publiss GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    PUBBlurEffectStyleDark = 0,
    PUBBlurEffectStyleLight
} PUBBlurEffectStyle;

@interface PUBConfig : NSObject


// WEBSERVICE
////////////////////////////////////////////////////////////////////////////////////////////////////

@property (nonatomic, strong) NSURL *webserviceBaseURL;
@property (nonatomic, strong) NSString *authToken;
@property (nonatomic, strong) NSString *appToken;
@property (nonatomic, strong) NSString *appSecret;


// APPEARENCE
////////////////////////////////////////////////////////////////////////////////////////////////////

@property (nonatomic, strong) UIColor *primaryColor;
@property (nonatomic, strong) UIColor *secondaryColor;
@property (nonatomic, strong) UIColor *kioskBackgroundColor;
@property (nonatomic, assign) UIStatusBarStyle statusBarStyle;

/// Specify if labels are shown below each issue in the kiosk
@property (nonatomic, assign) BOOL showLabelsBelowIssuesInKiosk;

/// Default is black
@property (nonatomic, assign) PUBBlurEffectStyle blurEffectStyle;

// LANGAUAGE
////////////////////////////////////////////////////////////////////////////////////////////////////

/// The preffered laguage that will be displayed when using the language feature with linked documents. By setting this, you opt into language support and activate language filtering.
@property (nonatomic, strong) NSString *preferredLanguage;

/// If there is no document in the preffered language, a document in the fallback language is displayed. The default is "en" when this property is not explicitly set.
@property (nonatomic, strong) NSString *fallbackLanguage;

/// If neither a preffered or fallback language is present, any localization will be shown or not. Default is "NO"
@property (nonatomic, assign) BOOL showAnyLocalizationIfThereIsNoFallback;

/// Specify if documents that have any localizations (linked and language categories) should be shown. Default is "YES"
@property (nonatomic, assign) BOOL showUnlocalizedDocuments;


// Google Analytics
////////////////////////////////////////////////////////////////////////////////////////////////////

@property (nonatomic, strong) NSString *googleAnalyticsTrackingCode;
@property (nonatomic, strong) NSNumber *pageTrackTime;


// IAP
////////////////////////////////////////////////////////////////////////////////////////////////////
@property (nonatomic, assign) BOOL inAppPurchaseActive;

+ (PUBConfig *)sharedConfig;

@end
