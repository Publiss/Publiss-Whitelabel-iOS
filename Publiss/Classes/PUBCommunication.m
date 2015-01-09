//
//  PUBCommunication.m
//  Publiss
//
//  Copyright (c) 2014 Publiss GmbH. All rights reserved.
//

#import "PUBCommunication.h"
#import "PUBDocumentFetcher.h"
#import "PUBDocument+Helper.h"
#import "PUBHTTPRequestManager.h"
#import "PUBStatisticsManager.h"
#import "PUBURLFactory.h"
#import "PublissCore.h"
#import "PUBConstants.h"

@implementation PUBCommunication

#pragma mark - Static

+ (instancetype)sharedInstance {
    static PUBCommunication *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [PUBCommunication new];
    });
    return _sharedInstance;
}

# pragma mark - fetch and save documents

- (void)fetchAndSaveDocuments:(void (^)())completionHandler
                        error:(void (^)(NSError *error))errorHandler {
    [PUBDocumentFetcher.sharedFetcher fetchDocumentList:^(BOOL success, NSError *error, NSDictionary *result) {
        if (success && result) {
            if ([NSJSONSerialization isValidJSONObject:result]) {
                NSArray *jsonData = (NSArray *)result[@"data"];
                NSMutableArray *deletedDocs = [NSMutableArray array];
                
                for (PUBDocument *document in [PUBDocument findAll]) {
                    [deletedDocs addObject:document.productID];
                }
                
                for (NSDictionary *documentInfo in jsonData) {
                    [deletedDocs removeObject:documentInfo[@"apple_product_id"]];
                    [PUBDocument createPUBDocumentWithDictionary:documentInfo];
                }
                
                for (NSString *productIDs in deletedDocs) {
                    PUBDocument *document = [PUBDocument findExistingPUBDocumentWithProductID:productIDs];
                    
                    // Delete all documents that were not downloaded.
                    if (document.state != PUBDocumentStateDownloaded) {
                        [document deleteEntity];
                    }
                }
                
                if (completionHandler) {
                    completionHandler();
                }
            }
            else {
                PUBLogError(@"JSON error: [%@ %@]", self.class, NSStringFromSelector(_cmd));
            }
            
            dispatch_queue_t statisticQueue = dispatch_queue_create("statistics_queue", NULL);
            dispatch_async(statisticQueue, ^{
                [self dispatchCachedStatisticData];
            });
        }
        else {
            PUBLogError(@"PUBCommunication: Error fetching and saving document list: %@", error.localizedDescription);
            if (completionHandler) {
                completionHandler();
            }
            if (errorHandler) {
                errorHandler(error);
            }
        }
    }];
}

- (void)dispatchCachedStatisticData  {
    
    NSArray *statistics = [PUBStatisticsManager.sharedInstance cachedStatistics];
    
    if ([statistics count]) {
        NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
        parameters[PUBStatisticsAppIDKey] = PUBStatisticsManager.sharedInstance.appID;
        parameters[PUBStatisticsEventKey] = statistics;
        parameters[PUBStatisticsDeviceIDKey] = UIDevice.currentDevice.model;
        parameters[PUBStatisticsiOSVersionKey] = UIDevice.currentDevice.systemVersion;
        NSString *trackingWebserviceURL = [PUBURLFactory createTrackingPathForPayload:parameters];
        
        if ([parameters isKindOfClass:[NSMutableDictionary class]]) {
            [PUBHTTPRequestManager.sharedRequestManager POST:trackingWebserviceURL
                                                  parameters:parameters
                                                     success:^(__unused AFHTTPRequestOperation *operation, id responseObject) {
                                                         [PUBStatisticsManager.sharedInstance clearCache];
                                                     }
                                                     failure:^(__unused AFHTTPRequestOperation *operation, NSError *error) {
                                                         PUBLog(@"%@: [FAILURE] dispatch statistic to %@ with statistic data: %@", [self class], trackingWebserviceURL, parameters);
                                                         PUBLog(@"Error Description: %@  / Error Reason: %@", error.localizedDescription, error.localizedFailureReason);
                                                     }];
        }
    }
    else {
        PUBLog(@"%@: No statistics to dispatch. ", [self class]);
    }
}

- (void)sendReceiptData:(NSData *)data
          withProductID:(NSString *)productID
            publishedID:(NSNumber *)publishedID 
             completion:(void(^)(id responseObject))completionBlock
                  error:(void(^)(NSError *error))errorBlock {
    if (!data || productID.length == 0 || !publishedID) {
        return;
    }
    
    NSDictionary *parameters = @{PUBProductID: productID,
                                 PUBReceiptData: [data base64EncodedStringWithOptions:0]};
    
    if ([NSJSONSerialization isValidJSONObject:parameters]) {
        [PUBHTTPRequestManager.sharedRequestManager POST:[PUBURLFactory createReceiptPathForPayLoad:parameters]
                                              parameters:parameters
                                                 success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                     PUBLog(@"%@: [SUCCESS] sending receipt data.", [self class]);
                                                     PUBLog(@"%@: Server response object: %@", [self class], responseObject);
                                                     if (completionBlock) (completionBlock(responseObject));
                                                 }
                                                 failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                     PUBLogError(@"%@: [FAILURE] sending receipt data: %@", [self class], error.localizedDescription);
                                                     if (errorBlock) errorBlock(error);
                                                 }];
    }
}

- (void)sendRestoreReceiptData:(NSData *)data
                    completion:(void(^)(id responseObject))completionBlock
                         error:(void(^)(NSError *error))errorBlock {
    if (!data) {
        return;
    }

    NSDictionary *parameters = @{PUBReceiptData: [data base64EncodedStringWithOptions:0]};
    
    if ([NSJSONSerialization isValidJSONObject:parameters]) {
        [PUBHTTPRequestManager.sharedRequestManager POST:[PUBURLFactory createReceiptRestorePathForPayLoad:parameters]
                                             parameters:parameters
                                                success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                    PUBLog(@"%@: [SUCCESS] sending restore receipt data.", [self class]);
                                                    if (completionBlock) (completionBlock(responseObject));
                                                }
                                                failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                    PUBLogError(@"%@: [FAILURE] sending restore receipt data: %@", [self class], error.localizedDescription);
                                                    PUBLog(@"Status Code: %ld", (long)[operation.response statusCode]);
                                                    if (errorBlock) errorBlock(error);
                                                }];
    }
}

- (void)sendLogin:(NSDictionary *)parameters
       completion:(void(^)(id responseObject))completionBlock
            error:(void(^)(NSError *error))errorBlock {
    
    if ([NSJSONSerialization isValidJSONObject:parameters]) {
        [PUBHTTPRequestManager.sharedRequestManager POST:[PUBURLFactory createAuthenticationLoginURLString:parameters]
                                              parameters:parameters
                                                 success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                     PUBLog(@"%@: [SUCCESS] sending login request.", [self class]);
                                                     PUBLog(@"%@: Server response object: %@", [self class], responseObject);
                                                     if (completionBlock) (completionBlock(responseObject));
                                                 }
                                                 failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                     PUBLogError(@"%@: [FAILURE] sending login request: %@", [self class], error.localizedDescription);
                                                     if (errorBlock) errorBlock(error);
                                                 }];
    }
}

@end
