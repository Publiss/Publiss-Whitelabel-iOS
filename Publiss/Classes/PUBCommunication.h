//
//  PUBCommunication.h
//  Publiss
//
//  Copyright (c) 2014 Publiss GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PUBCommunication : NSObject

+ (instancetype)sharedInstance;

- (void)fetchAndSaveDocuments:(void (^)())completionHandler
                        error:(void (^)(NSError *error))errorHandler;

- (void)dispatchCachedStatisticData;

- (void)sendReceiptData:(NSData *)data
          withProductID:(NSString *)productID
            publishedID:(NSNumber *)publishedID
             completion:(void(^)(id responseObject))completionBlock
                  error:(void(^)(NSError *error))errorBlock;

- (void)sendRestoreReceiptData:(NSData *)data
                    completion:(void(^)(id responseObject))completionBlock
                         error:(void(^)(NSError *error))errorBlock;

- (void)sendPushTokenToBackend:(NSString *)deviceId
                     pushToken:(NSString *)pushToken
                    deviceType:(NSString *)type
                      language:(NSString *)lang
                    completion:(void(^)(id responseObject))completionBlock
                         error:(void(^)(NSError *error))errorBlock;

#pragma mark - Publiss Authentication API

- (void)sendLogin:(NSDictionary *)parameters
       completion:(void(^)(id responseObject))completionBlock
            error:(void(^)(NSError *error))errorBlock;

@end
