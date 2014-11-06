//
//  PUBThumbnailImageCache.h
//  Publiss
//
//  Copyright (c) 2014 Publiss GmbH. All rights reserved.
//
//  Partly based on the SDImageChache class (c) Olivier Poitrey <rs@dailymotion.com>

#import <Foundation/Foundation.h>

@interface PUBThumbnailImageCache : NSObject

+ (PUBThumbnailImageCache *)sharedInstance;

- (UIImage *)thumbnailImageWithURLString:(NSString *)URLString;
- (void)setImage:(UIImage *)image forURLString:(NSString *)URLString;
- (void)removeImageWithURLString:(NSString *)URLString;
- (void)clearCache;

@end
