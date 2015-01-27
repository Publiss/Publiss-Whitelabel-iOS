//
//  PUBAuthentication.h
//  Publiss
//
//  Created by Lukas Korl on 17/12/14.
//  Copyright (c) 2014 Publiss GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PUBAuthentication : NSObject

@property (nonatomic, assign) BOOL loginEnabled;
@property (nonatomic, strong) NSArray *loginFields;
@property (nonatomic, strong) NSString *menuItemAccountField;
@property (nonatomic, strong) NSDictionary *additionalLoginParameters;

+ (instancetype)sharedInstance;

- (void)configureCommunications;
- (void)setLoggedInWithToken:(NSString *)token andMetadata:(NSDictionary *)metadata;
- (void)logout;
- (BOOL)isLoggedIn;
- (NSDictionary *)getMetadata;
- (NSString *)getAuthToken;

- (void)setPermissions:(NSDictionary *)permissions;
- (NSDictionary *)getPermissions;

@end
