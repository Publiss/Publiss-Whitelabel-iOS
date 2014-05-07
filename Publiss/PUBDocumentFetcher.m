//
//  PUBDocumentFetcher.m
//  Publiss
//
//  Copyright (c) 2014 Publiss GmbH. All rights reserved.
//

#import "PUBDocumentFetcher.h"
#import "PUBHTTPRequestManager.h"
#import "PUBDocument+Helper.h"
#import "PUBAppDelegate.h"
#import "IAPController.h"
#import "PUBURLFactory.h"

@interface PUBDocumentFetcher () <PSPDFDownloadManagerDelegate>
@property (nonatomic, strong) PSPDFDownloadManager *downloadManager;
@property (nonatomic, strong) NSMutableDictionary *fetchProgress;
@property (nonatomic, strong) NSMutableDictionary *documentProductCache;
@end

@implementation PUBDocumentFetcher

#pragma mark - NSObject

- (id)init {
    if (self = [super init]) {
        _downloadManager = [PSPDFDownloadManager new];
        _downloadManager.delegate = self;
        _fetchProgress = [NSMutableDictionary dictionary];
        _documentProductCache = [NSMutableDictionary dictionary];
    }
    return self;
}

#pragma mark - Static

+ (instancetype)sharedFetcher {
    static PUBDocumentFetcher *_sharedFetcher = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ _sharedFetcher = [PUBDocumentFetcher new]; });
    return _sharedFetcher;
}

#pragma mark - Load document(s) from server

- (void)fetchDocumentList:(void (^)(BOOL success, NSError *error, NSDictionary *result))completionHandler {
    NSString *publishedDocumentURLString = [PUBURLFactory createPublishedDocumentsPath];
    NSDictionary *signedParameters = [PUBURLFactory createSignedParameters:[NSMutableDictionary dictionary] forPath:publishedDocumentURLString];
    
    if ([signedParameters isKindOfClass:NSDictionary.class] && signedParameters != nil) {
        [PUBHTTPRequestManager.sharedRequestManager GET:publishedDocumentURLString
                                             parameters:signedParameters
                                                success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                    if (completionHandler) completionHandler(YES, nil, responseObject);
                                                }
                                                failure:^(AFHTTPRequestOperation * operation, NSError * error) {
                                                    PUBLogError(@"Error fetchting Documentlist: %@, Error-Code: %tu Parameters: %@", error.localizedDescription, operation.response.statusCode, signedParameters);
                                                    if (completionHandler) completionHandler(NO, error, nil);
                                                }];
    }
}

- (void)fetchDocument:(PUBDocument *)document page:(NSUInteger)page enqueueAtFront:(BOOL)enqueueAtFront completionHandler:(void (^)(NSString *productID, NSUInteger page))completionHandler {
    PUBAssert(document);
    PUBLogVerbose(@"Downloading Page %tu of document %@", page, document.title);
    
    // Get the target URLs.
    NSURL *downloadURL = [PUBURLFactory createDownloadURLForDocument:document.publishedID
                                                                page:page
                                                           iapSecret:[IAPController.sharedInstance iAPSecretForProductID:document.productID]
                                                           productId:document.productID];
    
    NSURL *targetURL = [document localDocumentURLForPage:page];

    // Check if we're currently downloading
    PSPDFRemoteFileObject *existingDownload = [self remoteContentObjectForDocument:document page:page];
    if (!existingDownload.isLoadingRemoteContent) {
        if (existingDownload) {
            [self.downloadManager cancelObject:existingDownload];
        }
        
        // Initiate the download.
        PSPDFRemoteFileObject *remotePDFPage = [[PSPDFRemoteFileObject alloc] initWithRemoteURL:downloadURL targetURL:targetURL];
        remotePDFPage.userInfo = @{@"page": @(page),
                                   @"apple_product_id": document.productID};
        [remotePDFPage setCompletionBlock:^(id<PSPDFRemoteContentObject>remoteObject) {
            if (completionHandler) {
               completionHandler(document.productID, page);
            }
            [self setProgressForDocumentProductID:document.productID onPage:page progress:1.0f];
        }];
        [self.downloadManager enqueueObject:remotePDFPage atFront:enqueueAtFront];
    }
}

- (PSPDFRemoteFileObject *)remoteContentObjectForDocument:(PUBDocument *)document page:(NSUInteger)page {
    NSURL *downloadURL = [PUBURLFactory createDownloadURLForDocument:document.publishedID
                                                                page:page
                                                           iapSecret:[IAPController.sharedInstance iAPSecretForProductID:document.productID]
                                                           productId:document.productID];

    NSArray *remoteObjects = [self.downloadManager objectsPassingTest:^BOOL(id <PSPDFRemoteContentObject> obj, NSUInteger index, BOOL *stop) {
        return [obj isKindOfClass:PSPDFRemoteFileObject.class] && [((PSPDFRemoteFileObject *)obj).remoteURL isEqual:downloadURL];
    }];
    return remoteObjects.firstObject;
}

- (void)fetchMetadataForDocument:(PUBDocument *)document completionBlock:(void (^)(PUBDocument *document, NSURL *XFDFURL, NSError *error))completionBlock {
    if (![NSFileManager.defaultManager fileExistsAtPath:document.localXFDFURL.path]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            [self fetchXFDFForDocument:document completionBlock:completionBlock];
        });
    }
}

- (NSURL *)XFDFURLForDocument:(PUBDocument *)document {
    NSString *urlString = [PUBURLFactory createXDFURLForDocument:document.publishedID];
    return [NSURL URLWithString:urlString];
}

- (void)fetchXFDFForDocument:(PUBDocument *)document completionBlock:(void (^)(PUBDocument *document, NSURL *XFDFURL, NSError *error))completionBlock {
    NSURL *XFDFURL = [self XFDFURLForDocument:document];
    NSData *data = [NSData dataWithContentsOfURL:XFDFURL];
    NSString *xfdfString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSError *error = nil;
    if (![xfdfString writeToFile:document.localXFDFURL.path atomically:YES encoding:NSUTF8StringEncoding error:&error]) {
        PUBLogWarning(@"Failed to write metadata: %@", error.localizedDescription);
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        if (completionBlock) completionBlock(document, XFDFURL, error);
    });
}

#pragma mark - helper methods

- (void)setPageAlreadyExsists:(PUBDocument *)document page:(NSUInteger)page {
    PUBAssert(document);
    [self setProgressForDocumentProductID:document.productID onPage:page progress:1.0f];
}

- (void)prefillProgressWithEmptyPageProgress:(PUBDocument *)document {
    if ([document isKindOfClass:PUBDocument.class]) {
        self.fetchProgress[document.productID] = [[NSMutableDictionary dictionary] mutableCopy];
        self.fetchProgress[document.productID][@"totalProgress"] = @(0);
        self.fetchProgress[document.productID][@"pageProgress"] = [[NSMutableArray array] mutableCopy];
        
        for (NSUInteger page = 0; page < document.pageCount; page++) {
            [self.fetchProgress[document.productID][@"pageProgress"] setObject:@(0) atIndexedSubscript:page];
        }
    }
}

- (void)setProgressForDocumentProductID:(NSString *)productID onPage:(NSInteger)page progress:(CGFloat)progress {
    if (!self.documentProductCache[productID]) {
        self.documentProductCache[productID] = [PUBDocument findExistingPUBDocumentWithProductID:productID];
    }
    
    PUBDocument *document = self.documentProductCache[productID];
    if (![self.fetchProgress[document.productID] count]) {
        [self prefillProgressWithEmptyPageProgress:document];
    }
    
    [self.fetchProgress[productID][@"pageProgress"] setObject:@(progress) atIndexedSubscript:(NSUInteger) page];
    CGFloat totalProgress = [self calculateTotalProgressForDocumentWithProductID:productID];
    [NSNotificationCenter.defaultCenter postNotificationName:PUBDocumentFetcherUpdateNotification object:nil userInfo:self.fetchProgress.mutableCopy];
    if (totalProgress >= 1.0f) {
        if (document.state != PUBDocumentStateDownloaded) {
            [self documentDownloadFinished:document];
        }
        document.state = PUBDocumentStateDownloaded;
        [(PUBAppDelegate *)UIApplication.sharedApplication.delegate saveContext];
        [self.fetchProgress removeObjectForKey:productID];
        [self.documentProductCache removeObjectForKey:productID];
        
    }
}

- (void)documentDownloadFinished:(PUBDocument *)document {
    [NSNotificationCenter.defaultCenter postNotificationName:PUBDocumentDownloadNotification
                                                      object:nil
                                                    userInfo:@{PUBStatisticsTimestampKey: [NSString stringWithFormat:@"%.0f",
                                                                                           NSDate.date.timeIntervalSince1970],
                                                               PUBStatisticsDocumentIDKey: document.productID,
                                                               PUBStatisticsEventKey: PUBStatisticsEventDownloadKey}];
}

- (CGFloat)calculateTotalProgressForDocumentWithProductID:(NSString *)productID {
    CGFloat totalProgress = 0.f;
    NSInteger pagesDoneCount = 0;
    
    for (NSNumber *progress in self.fetchProgress[productID][@"pageProgress"]) {
        totalProgress += progress.floatValue;
        if (progress.floatValue >= 1.0f) {
            pagesDoneCount++;
        }
    }
    
    totalProgress = totalProgress / [((NSMutableArray *)self.fetchProgress[productID][@"pageProgress"]) count];
    self.fetchProgress[productID][@"totalProgress"] = @(totalProgress);
    return totalProgress;
}

#pragma mark - Image Helper

- (NSURL *)imageForDocumentOptimized:(PUBDocument *)document page:(NSUInteger)page {
    NSString *imageURLString = [PUBURLFactory createImageURLStringForDocument:document.publishedID page:page parameters: @{@"optimized" : @"1"}];
    return [NSURL URLWithString:imageURLString];
}

- (NSURL *)imageForDocument:(PUBDocument *)document page:(NSUInteger)page size:(CGSize)size {
    return [self imageForDocument:document page:page size:size contentMode:UIViewContentModeCenter];
}

- (NSURL *)imageForDocument:(PUBDocument *)document page:(NSUInteger)page size:(CGSize)size contentMode:(UIViewContentMode)contentMode {
    // If we have a size, generate the correct string
    NSMutableDictionary *sizeParameter = [NSMutableDictionary dictionary];
    
    if (!CGSizeEqualToSize(size, CGSizeZero)) {

        // (no param) (UIViewContentModeCenter)
        // c = crop   (UIViewContentModeScaleAspectFill)
        // f = fill   (UIViewContentModeScaleAspectFit)
        // i = ignore (UIViewContentModeScaleToFill)
        NSString *cropMode;
        switch (contentMode) {
            case UIViewContentModeScaleToFill:     cropMode = @"i"; break;
            case UIViewContentModeScaleAspectFit:  cropMode = @"f"; break;
            case UIViewContentModeScaleAspectFill: cropMode = @"c"; break;
            default: cropMode = @"";
        }
        CGFloat screenScale = UIScreen.mainScreen.scale;
        NSString *sizeParam = [NSString stringWithFormat:@"%.0fx%.0f%@", size.width * screenScale, size.height * screenScale, cropMode];
        [sizeParameter setObject:sizeParam forKey:@"dim"];
    }
    NSString *imageURLString = [PUBURLFactory createImageURLStringForDocument:document.publishedID page:page parameters: sizeParameter];
    return [NSURL URLWithString:imageURLString];
}

#pragma mark - exclude file from iCloud Backup

- (BOOL)addSkipBackupAttributeToItemAtURL:(NSString *)URL {
    NSURL *localFileURL = [NSURL fileURLWithPath:URL];
    assert([NSFileManager.defaultManager fileExistsAtPath:URL]);
    
    NSError *error = nil;
    BOOL success = [localFileURL setResourceValue:@YES forKey:NSURLIsExcludedFromBackupKey error:&error];
    if (!success) {
        PUBLogWarning(@"Error excluding %@ from backup %@", URL.lastPathComponent, error);
    }
    return success;
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - PSDPFDownloadManagerDelegate

- (void)downloadManager:(PSPDFDownloadManager *)downloadManager didChangeObject:(id <PSPDFRemoteContentObject>)object {
    PSPDFRemoteFileObject *remoteFile = (PSPDFRemoteFileObject *)object;
    [self setProgressForDocumentProductID:remoteFile.userInfo[@"apple_product_id"] onPage:[remoteFile.userInfo[@"page"] integerValue] progress:remoteFile.remoteContentProgress];
    [NSNotificationCenter.defaultCenter postNotificationName:PUBDocumentFetcherUpdateNotification object:nil userInfo:self.fetchProgress];
}

@end
