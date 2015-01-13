//
//  PUBDocument+Helper.m
//  Publiss
//
//  Copyright (c) 2014 Publiss GmbH. All rights reserved.
//

#import "PUBDocument+Helper.h"
#import "PUBPDFDocument.h"
#import "PUBThumbnailImageCache.h"
#import "PUBCoreDataStack.h"
#import "PUBConstants.h"
#import "PUBDocumentFetcher.h"
#import "PUBLanguage+Helper.h"

@implementation PUBDocument (Helper)

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p \"%@\" size = %llu, productID = %@, state = %tu>.", self.class, self, self.title, self.size, self.productID, self.state];
}

#pragma mark - data model helpers

+ (PUBDocument *)createEntity {
    PUBDocument *newEntity = [NSEntityDescription insertNewObjectForEntityForName:@"PUBDocument"
                                                           inManagedObjectContext:PUBCoreDataStack.sharedCoreDataStack.managedObjectContext];

    return newEntity;
}

+ (PUBDocument *)createPUBDocumentWithDictionary:(NSDictionary *)dictionary {
    if (![dictionary isKindOfClass:NSDictionary.class] || dictionary.count == 0) {
        PUBLogWarning(@"Dictionary is empty.");
        return nil;
    }
    
    static NSDateFormatter *dateFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [NSDateFormatter new];
        dateFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US"];
        dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss'Z'";
    });
    NSDate *onlineUpdatedAt = [dateFormatter dateFromString:PUBSafeCast(dictionary[@"updated_at"], NSString.class)];
    NSDate *onlineFeaturedUpdatedAt = [dateFormatter dateFromString:PUBSafeCast(dictionary[@"featured_updated_at"], NSString.class)];
    
    BOOL shouldUpdateValues = NO;
    PUBDocument *document = [PUBDocument findExistingPUBDocumentWithProductID:dictionary[@"apple_product_id"]];
    // create new Document
    if (!document) {
        document = [PUBDocument createEntity];
        shouldUpdateValues = YES;
    } else {
        // Check if exsisting document should be updated
        shouldUpdateValues = ![document.updatedAt isEqualToDate:onlineUpdatedAt];
        
        // Save local annotations and delete PDF on update.
        if (shouldUpdateValues && document.state == PUBDocumentStateDownloaded) {
            PUBPDFDocument *pubPDFDocument = [PUBPDFDocument documentWithPUBDocument:document];
            [PUBPDFDocument saveLocalAnnotations:pubPDFDocument];
            [document deleteDocument:^{
                document.state = PUBDocumentStateUpdated;
            }];
        }
        
        // Update values if remote featured is different to local.
        BOOL remoteFeatured = [[dictionary valueForKeyPath:@"featured"] boolValue];
        BOOL localFeatured = document.featured;
        
        BOOL remoteShowInKiosk = [[dictionary valueForKeyPath:@"show_in_kiosk"] boolValue];
        BOOL localShowInKiosk = document.showInKiosk;
        
        shouldUpdateValues = shouldUpdateValues || (remoteFeatured != localFeatured) || (remoteShowInKiosk != localShowInKiosk);
        
        // TODO: Use == on date object
        if(onlineFeaturedUpdatedAt &&
           ![[onlineFeaturedUpdatedAt laterDate:document.featuredUpdatedAt] isEqualToDate:document.featuredUpdatedAt]) {
            document.featuredUpdatedAt = onlineFeaturedUpdatedAt;
            [document removeFeaturedImage];
        }
    }
    
    if (shouldUpdateValues) {
        // Never trust external content.
        @try {
            document.publishedID = (uint16_t)[dictionary[@"id"] integerValue];
            document.productID = PUBSafeCast(dictionary[@"apple_product_id"], NSString.class);
            document.updatedAt = onlineUpdatedAt;
            document.priority = (uint16_t)[dictionary[@"priority"] integerValue];
            document.title = PUBSafeCast(dictionary[@"name"], NSString.class);
            document.pageCount = (uint16_t)[[dictionary valueForKeyPath:@"pages_info.count"] integerValue] - 1;
            document.fileDescription = PUBSafeCast(dictionary[@"description"], NSString.class);
            document.paid = [[dictionary valueForKeyPath:@"paid"] boolValue];
            document.fileSize = (uint64_t) [dictionary[@"file_size"] longLongValue];
            document.featured = [[dictionary valueForKeyPath:@"featured"] boolValue];
            document.showInKiosk = [[dictionary valueForKeyPath:@"show_in_kiosk"] boolValue];
            document.featuredUpdatedAt = onlineFeaturedUpdatedAt;
            
            // Progressive download support
            document.sizes = PUBSafeCast([dictionary valueForKeyPath:@"pages_info.sizes"], NSArray.class);
            document.dimensions = PUBSafeCast([dictionary valueForKeyPath:@"pages_info.dimensions"], NSArray.class);
            
            document.language = [PUBLanguage createOrUpdateWithDocument:document
                                                          andDictionary:PUBSafeCast([dictionary valueForKeyPath:@"language"], NSDictionary.class)];
        }
        @catch (NSException *exception) {
            PUBLogError(@"Exception while parsing JSON: %@", exception);
        }
    }

    return document;
}


+ (PUBDocument *)findExistingPUBDocumentWithProductID:(NSString *)productID {
    NSFetchRequest *fetchRequest = [NSFetchRequest new];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"productID = %@", productID];
    fetchRequest.entity = [self getEntity];

    NSArray *fetchedResults = [PUBCoreDataStack.sharedCoreDataStack.managedObjectContext executeFetchRequest:fetchRequest error:NULL];
    return fetchedResults.firstObject;
}

+ (NSArray *)findAll {
    return [self findWithPredicate:nil];
}

+ (NSArray *)fetchAllSortedBy:(NSString *)sortKey ascending:(BOOL)ascending predicate:(NSPredicate *)predicate {
    NSFetchRequest *fetchRequest = [NSFetchRequest new];
    fetchRequest.entity = [self getEntity];

    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortKey ascending:ascending];
    fetchRequest.sortDescriptors = @[sortDescriptor];

    if (predicate != nil) {
        fetchRequest.predicate = predicate;
    }
    
    NSError *error = nil;
    NSArray *results = [PUBCoreDataStack.sharedCoreDataStack.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if (error) {
        PUBLogError(@"Error while fetching documents: %@", error);
    }

    return results ? results : [NSArray new];
}

+ (NSArray *)fetchAllWithPrefferedLanguage:(NSString *)language sortedBy:(NSString *)sortKey ascending:(BOOL)ascending predicate:(NSPredicate *)predicate {
    NSArray *allWithPrefferedLanguage = [PUBDocument fetchAllWithPrefferedLanguage:language];
    NSArray *allWithPredicate = [allWithPrefferedLanguage filteredArrayUsingPredicate:predicate];
    return [allWithPredicate sortedArrayUsingDescriptors:@[[[NSSortDescriptor alloc] initWithKey:sortKey ascending:ascending]]];
}

+ (NSArray *)fetchAllWithPrefferedLanguage:(NSString *)language {
    
    NSArray *allDistinctTags = [PUBLanguage fetchAllUniqueLinkedTags];
    
    NSMutableArray *prefferedDocuemtns = [NSMutableArray new];
    for (NSString *virtualDocumentLinkedTag in allDistinctTags) {
        NSArray *realDocuments = [PUBDocument findWithPredicate:[NSPredicate predicateWithFormat:@"language.linkedTag == %@", virtualDocumentLinkedTag]];
        
        NSArray *realDocsWithPrefferedLanguage = [realDocuments filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"language.languageTag == %@", language]];
        
        if (realDocsWithPrefferedLanguage.count > 0) {
            [prefferedDocuemtns addObject:realDocsWithPrefferedLanguage.firstObject];
        }
        else {
            [prefferedDocuemtns addObject:realDocuments.firstObject];
        }
    }
    
    NSArray *allWithoutLanguage = [PUBDocument findWithPredicate:[NSPredicate predicateWithFormat:@"language == NULL"]];
    return [prefferedDocuemtns arrayByAddingObjectsFromArray:allWithoutLanguage];
}

+ (NSArray *)fetchAllWithPrefferedLanguage:(NSString *)language
                          fallbackLanguage:(NSString *)fallback
           showingLocalizationIfNoFallback:(BOOL)showingLocalizationIfNoFallback
                  showUnlocalizedDocuments:(BOOL)showUnlocalizedDocuments {
    NSArray *allDistinctTags = [PUBLanguage fetchAllUniqueLinkedTags];
    
    NSMutableArray *prefferedDocuments = [NSMutableArray new];
    for (NSString *virtualDocumentLinkedTag in allDistinctTags) {
        NSArray *realDocuments = [PUBDocument findWithPredicate:[NSPredicate predicateWithFormat:@"language.linkedTag == %@", virtualDocumentLinkedTag]];
        
        NSArray *realDocsWithPrefferedLanguage = [realDocuments filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"language.languageTag == %@", language]];
        
        if (realDocsWithPrefferedLanguage.count > 0) {
            [prefferedDocuments addObject:realDocsWithPrefferedLanguage.firstObject];
        }
        else {
            
            NSArray *realDocsWithFallbackLanguage = [realDocuments filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"language.languageTag == %@", fallback]];
            
            if (realDocsWithFallbackLanguage.count > 0) {
                [prefferedDocuments addObject:realDocsWithPrefferedLanguage.firstObject];
            }
            else if (showingLocalizationIfNoFallback) {
                [prefferedDocuments addObject:realDocuments.firstObject];
            }
        }
    }
    
    NSArray *allWithoutLanguage = [PUBDocument findWithPredicate:[NSPredicate predicateWithFormat:@"language == NULL"]];
    
    return showUnlocalizedDocuments ? [prefferedDocuments arrayByAddingObjectsFromArray:allWithoutLanguage] : prefferedDocuments;
}

+ (NSArray *)findWithPredicate:(NSPredicate *)predicate {
    NSFetchRequest *fetchRequest = [NSFetchRequest new];
    fetchRequest.predicate = predicate;
    fetchRequest.entity = [self getEntity];
    return [PUBCoreDataStack.sharedCoreDataStack.managedObjectContext executeFetchRequest:fetchRequest error:NULL];
}

+ (NSEntityDescription *)getEntity {
    return [NSEntityDescription entityForName:@"PUBDocument" inManagedObjectContext:PUBCoreDataStack.sharedCoreDataStack.managedObjectContext];
}

- (void)deleteEntity {
    [self.managedObjectContext deleteObject:self];
}

- (NSURL *)localDocumentURL {
    NSString *documentsPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;

    NSError *error;
    NSString *publissPath = [documentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"publiss/%@", self.productID]];
    NSFileManager *fileManager = [NSFileManager new];
    if (![fileManager fileExistsAtPath:publissPath]) {
        if (![fileManager createDirectoryAtPath:publissPath withIntermediateDirectories:YES attributes:nil error:&error]) {
            PUBLogError(@"Failed to create dir: %@", error.localizedDescription);
        }
    }
    return [NSURL fileURLWithPath:publissPath];
}

- (NSURL *)localDocumentURLForPage:(NSUInteger)page {
    return [self.localDocumentURL URLByAppendingPathComponent:[NSString stringWithFormat:@"%tu.pdf", page] isDirectory:NO];
}

+ (void)restoreDocuments {
    for (PUBDocument *document in [PUBDocument findAll]) {
        if (document.state == PUBDocumentStateLoading) {
            document.state = PUBDocumentStateOnline;
        }
    }
}

#pragma mark helper method

- (void)deleteDocument:(void (^)())completionBlock {
    if ([self.productID length]) {
        PUBDocument *document = self;
        
        NSError *clearCacheError = nil;
        NSError *error = nil;
        if (document && document.state == PUBDocumentStateDownloaded) {
            // remove pdf cache for document
            PUBPDFDocument *pubPDFDocument = [PUBPDFDocument documentWithPUBDocument:document];
            if ([PSPDFKit.sharedInstance.cache removeCacheForDocument:pubPDFDocument deleteDocument:YES error:&clearCacheError]) {
                PUBLogVerbose(@"PDF Cache for document %@ cleared.", document.title);
            } else {
                PUBLogError(@"Error clearing PDF Cache for document %@: %@", document.title, clearCacheError.localizedDescription);
            }
            
            // remove last view state
            if ([document removedLastViewState]) {
                PUBLogVerbose(@"Last ViewState with document %@ removed.", document.title);
            }
            
            
            if ([NSFileManager.defaultManager removeItemAtURL:document.localDocumentURL error:&error]) {
                PUBLogVerbose(@"Deleted Document from filesystem: %@", document.title);
            } else {
                PUBLogWarning(@"Error deleting document from filesystem: %@", error.localizedDescription);
            }
            
            
            if ([NSFileManager.defaultManager removeItemAtURL:document.localXFDFURL error:&error]) {
                PUBLogVerbose(@"Deleted Document XFDF from filesystem URL: %@", document.localXFDFURL);
            } else {
                PUBLogWarning(@"Error deleting XFDF from filesystem: %@", error.localizedDescription);
            }
            
            document.state = PUBDocumentStateOnline;
            [PUBCoreDataStack.sharedCoreDataStack saveContext];
            if (completionBlock) completionBlock();
        }
    }
}

+ (void)deleteAll {
    for (PUBDocument *document in [PUBDocument findAll]) {
        [document deleteDocument:NULL];
    }
    [PSPDFKit.sharedInstance.cache clearCache];
    [PUBThumbnailImageCache.sharedInstance clearCache];
    [PUBCoreDataStack.sharedCoreDataStack saveContext];
}

- (NSURL *)localXFDFURL {
    NSString *documentsPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSString *path = [documentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.xfdf", self.productID]];
    NSURL *fileXML = [NSURL fileURLWithPath:path];
    return fileXML;
}

#pragma mark - PSPDFKit Viewstate

- (PSPDFViewState *)lastViewState {
    PSPDFViewState *viewState = nil;

    NSData *viewStateData = [NSUserDefaults.standardUserDefaults objectForKey:[NSString stringWithFormat:@"@%@", self.productID]];
    @try {
        if (viewStateData) {
            viewState = [NSKeyedUnarchiver unarchiveObjectWithData:viewStateData];
        }
    }
    @catch (NSException *exception) {
        PUBLogError(@"Failed to load saved viewState: %@", exception);
        [NSUserDefaults.standardUserDefaults removeObjectForKey:[NSString stringWithFormat:@"@%@", self.productID]];
    }
    return viewState;
}

- (void)setLastViewState:(PSPDFViewState *)lastViewState {
    if (lastViewState) {
        NSData *viewStateData = [NSKeyedArchiver archivedDataWithRootObject:lastViewState];
        [NSUserDefaults.standardUserDefaults setObject:viewStateData
                                                forKey:[NSString stringWithFormat:@"@%@", self.productID]];
    } else {
        [NSUserDefaults.standardUserDefaults removeObjectForKey:[NSString stringWithFormat:@"@%@", self.productID]];
    }
}

- (BOOL)removedLastViewState {
    NSData *viewStateData = [NSUserDefaults.standardUserDefaults objectForKey:[NSString stringWithFormat:@"@%@", self.productID]];
    
    if (viewStateData) {
        [NSUserDefaults.standardUserDefaults removeObjectForKey:[NSString stringWithFormat:@"@%@", self.productID]];
        return YES;
    }
    return NO;
}

- (void)removeFeaturedImage {
    NSURL *featuredImageUrl = [PUBDocumentFetcher.sharedFetcher featuredImageForPublishedDocument:(NSUInteger)self.publishedID];
    [PUBThumbnailImageCache.sharedInstance removeImageWithURLString:featuredImageUrl.absoluteString];
}

#pragma mark - Data Wrappers

- (NSArray *)sizes {
    return [NSKeyedUnarchiver unarchiveObjectWithData:self.sizesData];
}

- (void)setSizes:(NSArray *)sizes {
    self.sizesData = [NSKeyedArchiver archivedDataWithRootObject:sizes];
}

- (NSArray *)dimensions {
    return [NSKeyedUnarchiver unarchiveObjectWithData:self.dimensionsData];
}

- (void)setDimensions:(NSArray *)dimensions {
    self.dimensionsData = [NSKeyedArchiver archivedDataWithRootObject:dimensions];
}

@end
