//
//  PUBHTTPRequestManager.h
//  Publiss
//
//  Copyright (c) 2014 Publiss GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

@interface PUBHTTPRequestManager : AFHTTPRequestOperationManager

+ (instancetype)sharedRequestManager;

@end
