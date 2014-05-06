//
//  IAPController.m
//  Publiss
//
//  Copyright (c) 2014 Publiss GmbH. All rights reserved.
//

#import "IAPController.h"
#import "PUBDocument+Helper.h"
#import "Lockbox.h"

@interface IAPController()

@property (nonatomic, strong) NSDictionary *iAPSecrets;

@end

@implementation IAPController

+ (IAPController *)sharedInstance {
    static IAPController *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[IAPController alloc] init];
    });
    return sharedInstance;
}

- (void)purchase:(PUBDocument *)document completion:(PurchaseCompletionBlock)completionBlock error:(ErrorBlock)errorBlock {
    [IAPManager.sharedIAPManager purchaseProductForId:document.productID
                                           completion:^(SKPaymentTransaction *transaction) {
                                               if (completionBlock) {
                                                   completionBlock(transaction);
                                               }
                                           }
                                                error:^(NSError *error) {
                                                    if (errorBlock) {
                                                        errorBlock(error);
                                                    }
                                                }];
}

- (void)fetchProductForDocument:(PUBDocument *)document completion:(ProductCompletionBlock)completionblock error:(ErrorBlock)errorBlock {
    [IAPManager.sharedIAPManager getProductsForIds:@[document.productID]
                                        completion:^(NSArray *products) {
                                            if (products.count == 0) {
                                                if (errorBlock) {
                                                    errorBlock([NSError errorWithDomain:@"IAPController" code:IAPControllerErrorNotAvailable userInfo:@{NSLocalizedDescriptionKey : @"No valid product available."}]);
                                                }
                                            }
                                            else {
                                                if (completionblock) {
                                                    completionblock(products.firstObject);
                                                }
                                            }
                                        }
                                             error:^(NSError *error) {
                                                 if (errorBlock) {
                                                     errorBlock(error);
                                                 }
                                             }];
    
}

- (BOOL)canPurchase {
    return [IAPManager.sharedIAPManager canPurchase];
}

- (void)restorePurchasesWithCompletion:(RestorePurchasesCompletionBlock)completionBlock {
    [IAPManager.sharedIAPManager restorePurchasesWithCompletion:completionBlock];
}

- (BOOL)hasPurchased:(NSString *)productID {
    NSDictionary *secrets = [Lockbox dictionaryForKey:PUBiAPSecrets];
    return [secrets.allKeys containsObject:productID];
}

- (void)clearPurchases {
    [Lockbox setDictionary:[NSDictionary dictionary] forKey:PUBiAPSecrets];
    [IAPManager.sharedIAPManager clearPurchases];
}

- (void)readReceiptDataWithCompletion:(void(^)(NSData *receipt))completionBlock error:(void(^)(NSError *error))errorBlock {
    // Load the receipt from the app bundle.
    __block NSData *receipt = [self _readReceipt:NULL];
    
    if (receipt == nil) {
        [IAPManager.sharedIAPManager refreshReceiptWithCompletion:^(NSError *error) {
            receipt = [self _readReceipt:&error];
            
            if (error || receipt == nil) {
                if (errorBlock) errorBlock(error);
            }
            else {
                if (completionBlock) completionBlock(receipt);
            }
        }];
    }
    else {
        if (completionBlock) completionBlock(receipt);
    }
}

- (NSData *)_readReceipt:(NSError **)error {
    NSURL *receiptURL = [[NSBundle mainBundle] appStoreReceiptURL];
    NSData *receipt = [NSData dataWithContentsOfURL:receiptURL options:0 error:error];
    return receipt;
}

- (NSDictionary *)iAPSecrets {
    if (!_iAPSecrets) {
        _iAPSecrets = [Lockbox dictionaryForKey:PUBiAPSecrets];
    }
    if (nil == _iAPSecrets) {
        _iAPSecrets = [NSDictionary dictionary];
    }
    return _iAPSecrets;
}

- (NSString *)iAPSecretForProductID:(NSString *)productID {
    return [self.iAPSecrets objectForKey:productID];
}

- (void)setIAPSecret:(NSString *)secret productID:(NSString *)productID {
    NSMutableDictionary *secretsDict = self.iAPSecrets.mutableCopy;
    [secretsDict setObject:secret forKey:productID];
    [Lockbox setDictionary:secretsDict forKey:PUBiAPSecrets];
    self.iAPSecrets = secretsDict;
}

@end
