//
//  PUBURLConfig.h
//  Publiss
//
//  Copyright (c) 2014 Publiss GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>



@interface PUBURLConfig : NSObject

+ (PUBURLConfig *)sharedConfig;

@property (nonatomic, strong) NSURL *webserviceBaseURL;
@property (nonatomic, strong) NSString *authToken;
@property (nonatomic, strong) NSString *appToken;
@property (nonatomic, strong) NSString *appSecret;

@end
