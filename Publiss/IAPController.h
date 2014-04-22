//
//  IAPController.h
//  Publiss
//
//  Copyright (c) 2014 Publiss GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
#import "IAPManager.h"

@class PUBDocument;

typedef void(^PurchaseCompletionBlock)(SKPaymentTransaction *transaction);
typedef void(^ProductCompletionBlock)(SKProduct *product);
typedef void(^ErrorBlock)(NSError *error);

enum IAPControllerError {
    IAPControllerErrorNone,
    IAPControllerErrorNotAvailable
} typedef IAPControllerError;


@interface IAPController : NSObject

+ (IAPController *)sharedInstance;

- (void)purchase:(PUBDocument *)document completion:(PurchaseCompletionBlock)completionBlock error:(ErrorBlock)errorBlock;
- (void)restorePurchasesWithCompletion:(RestorePurchasesCompletionBlock)completionBlock;
- (void)fetchProductForDocument:(PUBDocument *)document completion:(ProductCompletionBlock)completionblock error:(ErrorBlock)errorBlock;
- (BOOL)canPurchase;
- (BOOL)hasPurchased:(NSString *)productID;
- (void)clearPurchases;
- (void)readReceiptDataWithCompletion:(void(^)(NSData *receipt))completionBlock error:(void(^)(NSError *error))errorBlock;

@end
