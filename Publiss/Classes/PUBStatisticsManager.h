//
//  PUBStatisticsManager.h
//  Publiss
//
//  Copyright (c) 2014 Publiss GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PUBStatisticsManager : NSObject

+ (instancetype)sharedInstance;
@property (nonatomic, copy, readonly) NSString *appID;
@property (nonatomic, copy) NSArray *cachedStatistics;

- (void)clearCache;

@end
