//
//  PUBURLFactory.h
//  Publiss
//
//  Created by Daniel Griesser on 09.04.14.
//  Copyright (c) 2014 Publiss GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PUBURLFactory : NSObject

+ (NSString *)createPreviewImageURLStringForDocument:(uint64_t)publishedDocumentId page:(uint64_t)pageIndex;
+ (NSString *)createXDFURLForDocument:(uint64_t)publishedDocumentId;
+ (NSString *)createImageURLStringForDocument:(uint64_t)publishedDocumentId page:(uint64_t)pageIndex parameters:(NSDictionary *)parameters;
+ (NSURL *)createDownloadURLForDocument:(uint64_t)publishedDocumentId page:(NSUInteger)pageIndex iapSecret:(NSString *)iapSecret productId:(NSString*)productId;

+ (NSString *)createPublishedDocumentsPath;

+ (NSString *)createTrackingPathForPayload:(NSDictionary *)payload;
+ (NSString *)createReceiptPathForPayLoad:(NSDictionary *)payload;
+ (NSString *)createReceiptRestorePathForPayLoad:(NSDictionary *)payload;

+ (NSDictionary *)createSignedParameters:(NSDictionary *)parameters forPath:(NSString *)path;

@end
