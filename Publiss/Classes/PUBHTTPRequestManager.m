//
//  PUBHTTPClient.m
//  Publiss
//
//  Copyright (c) 2014 Publiss GmbH. All rights reserved.
//

#import "PUBHTTPRequestManager.h"
#import "AFNetworkActivityIndicatorManager.h"
#import <PublissCore.h>
#import "PUBConfig.h"

@implementation PUBHTTPRequestManager

- (id)init {
    if ((self = [super initWithBaseURL:PUBConfig.sharedConfig.webserviceBaseURL])) {
        self.requestSerializer = [AFJSONRequestSerializer serializer];
        [self.reachabilityManager startMonitoring];
        [AFNetworkActivityIndicatorManager.sharedManager setEnabled:YES];
    }
    return self;
}

+ (instancetype)sharedRequestManager {
    static PUBHTTPRequestManager *_sharedPUBHTTPRequestManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ _sharedPUBHTTPRequestManager = [PUBHTTPRequestManager new]; });
    return _sharedPUBHTTPRequestManager;
}

@end
