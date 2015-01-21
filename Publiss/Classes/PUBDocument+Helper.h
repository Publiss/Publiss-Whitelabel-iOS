//
//  PUBDocument+Helper.h
//  Publiss
//
//  Copyright (c) 2014 Publiss GmbH. All rights reserved.
//

#import "PUBDocument.h"

typedef NS_ENUM(int16_t, PUBDocumentState) {
    PUBDocumentStateOnline,
    PUBDocumentStateDownloaded,
    PUBDocumentStateLoading,
    PUBDocumentStatePurchased,  // just for UI stuff
    PUBDocumentStateUpdated,
    PUBDocumentStateNew,
};

@class PSPDFViewState;

@interface PUBDocument (Helper)

@property (strong, nonatomic) PSPDFViewState *lastViewState;

+ (PUBDocument *)createEntity;
+ (PUBDocument *)createPUBDocumentWithDictionary:(NSDictionary *)dictionary;
+ (PUBDocument *)findExistingPUBDocumentWithProductID:(NSString *)productID;

+ (NSArray *)findAll;
+ (NSArray *)fetchAllSortedBy:(NSString *)sortKey ascending:(BOOL)ascending predicate:(NSPredicate *)predicate;

+ (NSArray *)fetchAllWithPreferredLanguage:(NSString *)language
                          fallbackLanguage:(NSString *)fallback
           showingLocalizationIfNoFallback:(BOOL)showingLocalizationIfNoFallback
                  showUnlocalizedDocuments:(BOOL)showUnlocalizedDocuments;

+ (NSArray *)sortDocuments:(NSArray *)documents
                  sortedBy:(NSString *)sortKey
                 ascending:(BOOL)ascending
                 predicate:(NSPredicate *)predicate;



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

- (void)documentSeen;
+ (BOOL)shouldShowNewFlag;
+ (void)setShouldShowNewFlag:(BOOL)flag;

@property (copy, nonatomic) NSArray *sizes;      // wrapped integers
@property (copy, nonatomic) NSArray *dimensions; // wrapped CGSizes.

@end
