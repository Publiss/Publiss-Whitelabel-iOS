//
//  PUBCommunication.h
//  Publiss
//
//  Copyright (c) 2014 Publiss GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PUBCommunication : NSObject

+ (instancetype)sharedInstance;

- (void)fetchAndSaveDocuments:(void (^)())completionHandler;

- (void)dispatchCachedStatisticData;

- (void)sendReceiptData:(NSData *)data
          withProductID:(NSString *)productID
            publishedID:(NSNumber *)publishedID
             completion:(void(^)(id responseObject))completionBlock
                  error:(void(^)(NSError *error))errorBlock;

- (void)sendRestoreReceiptData:(NSData *)data
                    completion:(void(^)(id responseObject))completionBlock
                         error:(void(^)(NSError *error))errorBlock;

@end
