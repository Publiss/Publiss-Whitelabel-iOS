//
//  PUBDocument+Helper.h
//  Publiss
//
//  Copyright (c) 2014 Publiss GmbH. All rights reserved.
//

#import "PUBDocument.h"
#import "PSPDFKit.h"

typedef NS_ENUM(int16_t, PUBDocumentState) {
    PUBDocumentStateOnline,
    PUBDocumentStateDownloaded,
    PUBDocumentStateLoading,
    PUBDocumentPurchased,  // just for UI stuff
    PUBDocumentStateUpdated
};

@interface PUBDocument (Helper)

@property (strong, nonatomic) PSPDFViewState *lastViewState;

// Fetch helper
+ (PUBDocument *)findExistingPUBDocumentWithProductID:(NSString *)productID;
+ (NSArray *)findAll;
+ (NSArray *)fetchAllSortedBy:(NSString *)sortKey ascending:(BOOL)ascending predicate:(NSPredicate *)predicate;
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
- (void)removeFeaturedImage;

@property (copy, nonatomic) NSArray *sizes;      // wrapped integers
@property (copy, nonatomic) NSArray *dimensions; // wrapped CGSizes.

@end
