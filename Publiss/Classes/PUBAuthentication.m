//
//  PUBAuthentication.m
//  Publiss
//
//  Created by Lukas Korl on 17/12/14.
//  Copyright (c) 2014 Publiss GmbH. All rights reserved.
//

#import "PUBAuthentication.h"
#import "PUBConfig.h"
#import "NSDictionary+Cleanup.h"
#import "PUBConstants.h"

@implementation PUBAuthentication

#pragma mark - Static

+ (instancetype)sharedInstance {
    static PUBAuthentication *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [PUBAuthentication new];
        _sharedInstance.loginFields = @[
                                        @{@"title": @"Email",      @"class": @"PUBUserLoginTextFieldCell",         @"parameter_name": @"username"},
                                        @{@"title": @"Password",   @"class": @"PUBUserLoginPasswordFieldCell",     @"parameter_name": @"password"}
                                        ];
        _sharedInstance.menuItemAccountField = @"email";
        _sharedInstance.loginEnabled = NO;
    });
    return _sharedInstance;
}

#pragma mark - System helpers

- (void)configureCommunications {
    if ([self isLoggedIn]) {
        PUBConfig.sharedConfig.authToken = [self getAuthToken];
    }
}

#pragma mark - Authentication methods

- (void)setLoggedInWithToken:(NSString *)token andMetadata:(NSDictionary *)metadata {
    
    NSDictionary *cleanMetadata = [metadata dictionaryWithoutEmptyStringsForMissingValues];
    [NSUserDefaults.standardUserDefaults setObject:token forKey:@"com.publiss.extauth.user.token"];
    [NSUserDefaults.standardUserDefaults setObject:cleanMetadata forKey:@"com.publiss.extauth.user.meta"];
    [NSUserDefaults.standardUserDefaults synchronize];
    
    PUBConfig.sharedConfig.authToken = token;
}

- (void)logout {
    [NSUserDefaults.standardUserDefaults removeObjectForKey:@"com.publiss.extauth.user.token"];
    [NSUserDefaults.standardUserDefaults removeObjectForKey:@"com.publiss.extauth.user.meta"];
    [NSUserDefaults.standardUserDefaults removeObjectForKey:@"com.publiss.extauth.permissions"];
    [NSUserDefaults.standardUserDefaults synchronize];
    
    PUBConfig.sharedConfig.authToken = nil;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:PUBAuthenticationLogoutSuccess object:nil];
}

- (BOOL)isLoggedIn {
    return [NSUserDefaults.standardUserDefaults objectForKey:@"com.publiss.extauth.user.token"] != nil;
}

- (NSDictionary *)getMetadata {
    return (NSDictionary *)[[NSUserDefaults standardUserDefaults] dictionaryForKey:@"com.publiss.extauth.user.meta"];
}

- (NSString *)getAuthToken {
    return (NSString *)[[NSUserDefaults standardUserDefaults] objectForKey:@"com.publiss.extauth.user.token"];
}

- (void)setPermissions:(NSDictionary *)permissions {
    NSDictionary *cleanPermissions = [permissions dictionaryWithoutEmptyStringsForMissingValues];
    [NSUserDefaults.standardUserDefaults setObject:cleanPermissions forKey:@"com.publiss.extauth.permissions"];
}

- (NSDictionary *)getPermissions {
    return (NSDictionary *)[[NSUserDefaults standardUserDefaults] objectForKey:@"com.publiss.extauth.permissions"];
}

@end
