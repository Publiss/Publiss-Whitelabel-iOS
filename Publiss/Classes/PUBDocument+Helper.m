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
    
    BOOL shouldUpdateValues = NO;
    PUBDocument *document = [PUBDocument findExistingPUBDocumentWithProductID:dictionary[@"apple_product_id"]];
    // create new Document
    if (!document) {
        document = [PUBDocument createEntity];
        shouldUpdateValues = YES;
    } else {
        //check if exsisting document should be updated
        shouldUpdateValues = ![document.updatedAt isEqualToDate:onlineUpdatedAt];
        if (shouldUpdateValues && document.state == PUBDocumentStateDownloaded) {
            PUBPDFDocument *pubPDFDocument = [PUBPDFDocument documentWithPUBDocument:document];
            [PUBPDFDocument saveLocalAnnotations:pubPDFDocument];
            [document deleteDocument:^{
                document.state = PUBDocumentStateUpdated;
            }];
        }
    }
    
    if (shouldUpdateValues) {
        // Never trust external content.
        @try {
            document.productID = PUBSafeCast(dictionary[@"apple_product_id"], NSString.class);
            document.publishedID = (uint16_t)[dictionary[@"id"] integerValue];
            document.updatedAt = onlineUpdatedAt;
            document.priority = (uint16_t)[dictionary[@"priority"] integerValue];
            document.title = PUBSafeCast(dictionary[@"name"], NSString.class);
            document.pageCount = (uint16_t)[[dictionary valueForKeyPath:@"pages_info.count"] integerValue] - 1;
            document.fileDescription = PUBSafeCast(dictionary[@"description"], NSString.class);
            document.paid = [[dictionary valueForKeyPath:@"paid"] boolValue];
            document.fileSize = (uint64_t) [dictionary[@"file_size"] longLongValue];
            document.featured = [[dictionary valueForKeyPath:@"featured"] boolValue];
            
            // Progressive download support
            document.sizes = PUBSafeCast([dictionary valueForKeyPath:@"pages_info.sizes"], NSArray.class);
            document.dimensions = PUBSafeCast([dictionary valueForKeyPath:@"pages_info.dimensions"], NSArray.class);
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

+ (NSArray *)fetchAllSortedBy:(NSString *)sortKey ascending:(BOOL)ascending {
    NSFetchRequest *fetchRequest = [NSFetchRequest new];
    fetchRequest.entity = [self getEntity];

    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortKey ascending:ascending];
    fetchRequest.sortDescriptors = @[sortDescriptor];

    NSError *error = nil;
    NSArray *results = [PUBCoreDataStack.sharedCoreDataStack.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if (error) {
        PUBLogError(@"Error while fetching documents: %@", error);
    }

    return results ? results : [NSArray new];
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
            if ([PSPDFCache.sharedCache removeCacheForDocument:pubPDFDocument deleteDocument:YES error:&clearCacheError]) {
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
    [PSPDFCache.sharedCache clearCache];
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
