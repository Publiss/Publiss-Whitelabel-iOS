//
//  PUBConfig
//  Publiss
//
//  Created by Denis Andrasec on 26.01.15.
//  Copyright (c) 2015 Publiss GmbH. All rights reserved.
//

#import "PUBConfig.h"
#import "PUBURLConfig.h"

NSString *const DEFAULT_FALLBACK_LANGUAGE_EN = @"en";

@implementation PUBConfig

+ (PUBConfig *)sharedConfig {
    static dispatch_once_t _onceToken;
    static PUBConfig *_sharedAppearence = nil;
    dispatch_once(&_onceToken, ^{
        _sharedAppearence = [PUBConfig new];
        
        _sharedAppearence.fallbackLanguage = DEFAULT_FALLBACK_LANGUAGE_EN;
        _sharedAppearence.showAnyLocalizationIfThereIsNoFallback = NO;
        _sharedAppearence.showUnlocalizedDocuments = YES;
        _sharedAppearence.showLabelsBelowIssuesInKiosk = NO;
        
        _sharedAppearence.statusBarStyle = UIStatusBarStyleLightContent;
        [[UIApplication sharedApplication] setStatusBarStyle:_sharedAppearence.statusBarStyle];
    });
    return _sharedAppearence;
}

- (void)setStatusBarStyle:(UIStatusBarStyle)statusBarStyle {
    _statusBarStyle = statusBarStyle;
    [[UIApplication sharedApplication] setStatusBarStyle:_statusBarStyle];
}

// Call core methods

- (NSURL *)webserviceBaseURL {
    return PUBURLConfig.sharedConfig.webserviceBaseURL;
}

- (NSString *)authToken {
    return PUBURLConfig.sharedConfig.authToken;
}

- (NSString *)appToken {
    return PUBURLConfig.sharedConfig.appToken;
}

- (NSString *)appSecret {
    return PUBURLConfig.sharedConfig.appSecret;
}

- (void)setWebserviceBaseURL:(NSURL *)webserviceBaseURL {
    PUBURLConfig.sharedConfig.webserviceBaseURL = webserviceBaseURL;
}

- (void)setAuthToken:(NSString *)authToken {
    PUBURLConfig.sharedConfig.authToken = authToken;
}

- (void)setAppToken:(NSString *)appToken {
    PUBURLConfig.sharedConfig.appToken = appToken;
}

- (void)setAppSecret:(NSString *)appSecret {
    PUBURLConfig.sharedConfig.appSecret = appSecret;
}

@end
