//
//  PUBDocument+Helper.h
//  Publiss
//
//  Copyright (c) 2014 Publiss GmbH. All rights reserved.
//

#import "PUBDocument.h"

typedef NS_ENUM(int16_t, PUBDocumentState) {
    PUBDocumentStateOnline,
    PUBDocumentStateUpdated,
    PUBDocumentStateDownloaded,
    PUBDocumentStateLoading,
    PUBDocumentPurchased  // just for UI stuff
};

@interface PUBDocument (Helper)

@property (strong, nonatomic) PSPDFViewState *lastViewState;

// Fetch helper
+ (PUBDocument *)findExistingPUBDocumentWithProductID:(NSString *)productID;
+ (NSArray *)findAll;
+ (NSArray *)fetchAllSortedBy:(NSString *)sortKey ascending:(BOOL)ascending;
+ (PUBDocument *)createPUBDocumentWithDictionary:(NSDictionary *)dictionary;

/// deletes the file of the document and pspdfcache
- (void)deleteDocument:(void (^)())completionBlock;

+ (void)deleteAll;
+ (void)restoreDocuments;
- (void)deleteEntity;

- (NSURL *)localDocumentURL;
- (NSURL *)localDocumentURLForPage:(NSUInteger)page;

- (NSURL *)localXFDFURL;
- (BOOL)removedLastViewState;

- (NSString *)iapSecret;

@property (copy, nonatomic) NSArray *sizes;      // wrapped integers
@property (copy, nonatomic) NSArray *dimensions; // wrapped CGSizes.

@end
