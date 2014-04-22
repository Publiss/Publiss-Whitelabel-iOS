//
//  IAPManager.m
//  Classes
//
//  Created by Marcel Ruegenberg on 22.11.12.
//  Copyright (c) 2012 Dustlab. All rights reserved.
//

#import "IAPManager.h"
#import <Lockbox/Lockbox.h>

@interface IAPManager () <SKProductsRequestDelegate, SKPaymentTransactionObserver>
@property (strong) NSMutableDictionary *products;

@property (strong) NSMutableArray *productRequests;
@property (strong) NSMutableArray *payments;

@property (strong) NSMutableArray *purchasesChangedCallbacks;

@property (strong) SKReceiptRefreshRequest *receiptRefreshRequest;
@property (copy) RefreshReceiptCompletionBlock receiptRefreshCompletionBlock;

@property (copy) RestorePurchasesCompletionBlock restoreCompletionBlock;

@end

#define PURCHASES_KEY @"com.publiss.demo.purchases"

NSURL *purchasesURL() {
    NSURL *appDocDir = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    return [appDocDir URLByAppendingPathComponent:@".purchases.plist"];
}

@implementation IAPManager

+ (IAPManager *)sharedIAPManager {
    static IAPManager *sharedInstance;
    if(sharedInstance == nil) sharedInstance = [IAPManager new];
    return sharedInstance;
}

- (id)init {
    if((self = [super init])) {
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];

        self.products = [NSMutableDictionary dictionary];
        self.productRequests = [NSMutableArray array];
        self.payments = [NSMutableArray array];
        self.purchasesChangedCallbacks = [NSMutableArray array];
    }
    return self;
}

- (BOOL)hasPurchased:(NSString *)productID {
    return [[Lockbox setForKey:PURCHASES_KEY] containsObject:productID];
}

- (void)setPurchasedForProductID:(NSString *)productID {
    NSMutableSet *purchases = [NSMutableSet setWithSet:[Lockbox setForKey:PURCHASES_KEY]];
    [purchases addObject:productID];
    [Lockbox setSet:purchases forKey:PURCHASES_KEY];
}

#pragma mark - Product Information

- (void)getProductsForIds:(NSArray *)productIds
               completion:(ProductsCompletionBlock)completionBlock
                    error:(ErrorBlock)err {
    NSMutableArray *result = [NSMutableArray array];
    NSMutableSet *remainingIds = [NSMutableSet set];
    for(NSString *productId in productIds) {
        if([self.products objectForKey:productId])
            [result addObject:[self.products objectForKey:productId]];
        else
            [remainingIds addObject:productId];
    }
    
    if([remainingIds count] == 0) {
        completionBlock(result);
        return;
    }
    
    SKProductsRequest *req = [[SKProductsRequest alloc] initWithProductIdentifiers:remainingIds];
    req.delegate = self;
    [self.productRequests addObject:@[req, completionBlock, err]];
    [req start];
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    NSUInteger c = [self.productRequests count];
    for(int i = 0; i < c; ++i) {
        NSArray *tuple = [self.productRequests objectAtIndex:i];
        if([tuple objectAtIndex:0] == request) {
            ProductsCompletionBlock completion = [tuple objectAtIndex:1];
            completion(response.products);
            [self.productRequests removeObjectAtIndex:i];
            return;
        }
    }
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    if (request == self.receiptRefreshRequest) {
        if (self.receiptRefreshCompletionBlock) self.receiptRefreshCompletionBlock(error);
        return;
    }
    
    NSUInteger c = [self.productRequests count];
    for(int i = 0; i < c; ++i) {
        NSArray *tuple = [self.productRequests objectAtIndex:i];
        if([tuple objectAtIndex:0] == request) {
            ErrorBlock err = [tuple objectAtIndex:2];
            err([NSError errorWithDomain:@"IAPManager" code:0 userInfo:[NSDictionary dictionaryWithObject:@"Can't retrieve products" forKey:NSLocalizedDescriptionKey]]);
            [self.productRequests removeObjectAtIndex:i];
            return;
        }
    }
}

- (void)requestDidFinish:(SKRequest *)request {
    if (request == self.receiptRefreshRequest) {
        if (self.receiptRefreshCompletionBlock) self.receiptRefreshCompletionBlock(nil);
    }
}

#pragma mark - Purchase

- (void)refreshReceiptWithCompletion:(RefreshReceiptCompletionBlock)completionBlock {
    self.receiptRefreshRequest = [[SKReceiptRefreshRequest alloc] initWithReceiptProperties:nil];
    self.receiptRefreshRequest.delegate = self;
    self.receiptRefreshCompletionBlock = completionBlock;
    [self.receiptRefreshRequest start];
}

- (void)restorePurchases {
    [self restorePurchasesWithCompletion:nil];
}

- (void)restorePurchasesWithCompletion:(RestorePurchasesCompletionBlock)completionBlock {
    self.restoreCompletionBlock = completionBlock;
    return [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

- (void)clearPurchases {
    [Lockbox setSet:nil forKey:PURCHASES_KEY];
}

- (void)purchaseProduct:(SKProduct *)product completion:(PurchaseCompletionBlock)completionBlock error:(ErrorBlock)err {
#ifdef SIMULATE_PURCHASES
    [self.purchasedItems addObject:product.productIdentifier];
    self.purchasedItemsChanged = YES;
    for(NSArray *t in self.purchasesChangedCallbacks) {
        PurchasedProductsChanged callback = t[0];
        callback();
    }
    completionBlock(NULL);
#else
    if(! [SKPaymentQueue canMakePayments])
        err([NSError errorWithDomain:@"IAPManager" code:0 userInfo:[NSDictionary dictionaryWithObject:@"Can't make payments" forKey:NSLocalizedDescriptionKey]]);
    else {
        SKPayment *payment = [SKPayment paymentWithProduct:product];
        [self.payments addObject:@[payment.productIdentifier, completionBlock, err]];
        [[SKPaymentQueue defaultQueue] addPayment:payment];
    }
#endif
}

- (void)purchaseProductForId:(NSString *)productId completion:(PurchaseCompletionBlock)completionBlock error:(ErrorBlock)err {
#ifdef SIMULATE_PURCHASES
    [self.purchasedItems addObject:productId];
    self.purchasedItemsChanged = YES;
    for(NSArray *t in self.purchasesChangedCallbacks) {
        PurchasedProductsChanged callback = t[0];
        callback();
    }
    completionBlock(NULL);
#else
    [self getProductsForIds:@[productId]
                 completion:^(NSArray *products) {
                     if([products count] == 0) err([NSError errorWithDomain:@"IAPManager" code:0 userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"Didn't find products with ID %@", productId] forKey:NSLocalizedDescriptionKey]]);
                     else [self purchaseProduct:[products objectAtIndex:0] completion:completionBlock error:err];
                 }
                      error:^(NSError *error) {
                      }];
#endif
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    BOOL newPurchases = NO;
    for(SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStateRestored: // sic!
            case SKPaymentTransactionStatePurchased: {
                [self setPurchasedForProductID:transaction.payment.productIdentifier];
                newPurchases = YES;
                [queue finishTransaction:transaction];
                break;
            }
            case SKPaymentTransactionStateFailed: {
                [queue finishTransaction:transaction];
                break;
            }
            case SKPaymentTransactionStatePurchasing: {
                PUBLogVerbose(@"%@ is being processed by the App Store...", transaction.payment.productIdentifier);
                break;
            }
            default: break;
        }
    }
    
    if(newPurchases) {
        for(NSArray *t in self.purchasesChangedCallbacks) {
            PurchasedProductsChanged callback = t[0];
            callback();
        }
    }
    
    for(SKPaymentTransaction *transaction in transactions) {
        // find the block and error block correspoding to this transaction
        NSUInteger c = [self.payments count];
        PurchaseCompletionBlock completion = nil;
        ErrorBlock err = nil;
        int paymentIndex = -1;
        for(int i = 0; i < c; ++i) {
            NSArray *t = [self.payments objectAtIndex:i];
            if([t[0] isEqual:transaction.payment.productIdentifier]) {
                completion = t[1];
                err = t[2];
                paymentIndex = i;
                break;
            }
        }
        
        switch (transaction.transactionState) {
            case SKPaymentTransactionStateRestored: // sic!
            case SKPaymentTransactionStatePurchased: {
                if (paymentIndex >= 0) {
                    [self.payments removeObjectAtIndex:paymentIndex];
                }
                if(completion) completion(transaction);
                break;
            }
            case SKPaymentTransactionStateFailed: {
                if (paymentIndex >= 0) {
                    [self.payments removeObjectAtIndex:paymentIndex];
                }
                if(err) err(transaction.error);
                break;
            }
            case SKPaymentTransactionStatePurchasing: {
                break;
            }
            default: break;
        }
    }
}

- (BOOL)canPurchase {
    return [SKPaymentQueue canMakePayments];
}

#pragma mark - Observation

- (void)addPurchasesChangedCallback:(PurchasedProductsChanged)callback withContext:(id)context {
    [self.purchasesChangedCallbacks addObject:@[callback, context]];
}

- (void)removePurchasesChangedCallbackWithContext:(id)context {
    NSUInteger c = [self.purchasesChangedCallbacks count];
    for(NSInteger i = c - 1; i >= 0; --i) {
        NSArray *t = self.purchasesChangedCallbacks[i];
        if(t[1] == context) {
            [self.purchasesChangedCallbacks removeObjectAtIndex:i];
        }
    }
}

- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue {
    if (self.restoreCompletionBlock) {
        self.restoreCompletionBlock(nil);
    }
    self.restoreCompletionBlock = nil;
}

- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error {
    if (self.restoreCompletionBlock) {
        self.restoreCompletionBlock(error);
    }
    self.restoreCompletionBlock = nil;
}

@end
