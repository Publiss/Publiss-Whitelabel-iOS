//
//  PUBDocumentFetcher.h
//  Publiss
//
//  Copyright (c) 2014 Publiss GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import "PSPDFKit.h"

@class PUBDocument;

@interface PUBDocumentFetcher : NSObject

+ (instancetype)sharedFetcher;

// fetch list of available documents from the server, document list not saved yet
- (void)fetchDocumentList:(void (^)(BOOL success, NSError *error, NSDictionary *result))completionHandler;

// Fetch single page.
- (void)fetchDocument:(PUBDocument *)document page:(NSUInteger)page enqueueAtFront:(BOOL)enqueueAtFront completionHandler:(void (^)(NSString *productID, NSUInteger page))completionHandler;

// Fetches document metadata (videos, etc)
- (void)fetchMetadataForDocument:(PUBDocument *)document completionBlock:(void (^)(PUBDocument *document, NSURL *XFDFURL, NSError *error))completionBlock;
- (void)setPageAlreadyExsists:(PUBDocument *)document page:(NSUInteger)page;

//+ (NSString *)getSignedParameterString;
//- (NSDictionary *)getSignedParameters:(NSDictionary *)parameters;

// If `size` is zero, the default server size will be sent.
// Only a subset of `UIViewContentMode` is supported: UIViewContentModeScaleAspectFill, UIViewContentModeScaleAspectFit, UIViewContentModeScaleToFill and UIViewContentModeCenter. The latter will return an image cropped to the smaller dimension of the size.
- (NSURL *)imageForDocument:(PUBDocument *)document page:(NSUInteger)page size:(CGSize)size contentMode:(UIViewContentMode)contentMode;
- (NSURL *)imageForDocument:(PUBDocument *)document page:(NSUInteger)page size:(CGSize)size;
// webserver optimized version for partial rendering (50% size, quality 5%, precached)
- (NSURL *)imageForDocumentOptimized:(PUBDocument *)document page:(NSUInteger)page;

// Get download status
- (PSPDFRemoteFileObject *)remoteContentObjectForDocument:(PUBDocument *)document page:(NSUInteger)page;

// Check if document is unpublished
- (void)checkIfDocumentIsUnpublished:(PUBDocument *)document competionHandler:(void (^)(BOOL unpublished))completionBlock;

@end
