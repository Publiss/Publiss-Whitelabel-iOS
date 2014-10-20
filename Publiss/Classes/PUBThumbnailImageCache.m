//
//  PUBThumbnailImageCache.m
//  Publiss
//
//  Copyright (c) 2014 Publiss GmbH. All rights reserved.
//
//  Partly based on the SDImageChache class (c) Olivier Poitrey <rs@dailymotion.com>

#import "PUBThumbnailImageCache.h"
#import "PSPDFKit.h"
#import "PUBConstants.h"
#import <CommonCrypto/CommonDigest.h>

@interface PUBThumbnailImageCache ()
@property (nonatomic, strong) NSString *cacheDirectory;
@property (nonatomic, strong) dispatch_queue_t ioQueue;
@end

@implementation PUBThumbnailImageCache

- (id)init {
    if ((self = [super init])) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        self.cacheDirectory = [paths.firstObject stringByAppendingPathComponent:@"_thumbcache"];
        self.ioQueue = dispatch_queue_create("com.publiss.thumbnailcache", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

+ (PUBThumbnailImageCache *)sharedInstance {
    static PUBThumbnailImageCache *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ _sharedInstance = [[PUBThumbnailImageCache alloc] init]; });
    return _sharedInstance;
}

- (UIImage *)thumbnailImageWithURLString:(NSString *)URLString {
    NSString *defaultPath = [self cacheFilePathForURLString:URLString];
    NSData *imageData = [NSData dataWithContentsOfFile:defaultPath];

    if (imageData) {
        return [[UIImage alloc] initWithData:imageData];
    } else {
        return nil;
    }
}

- (void)setImage:(UIImage *)image forURLString:(NSString *)URLString {
    dispatch_async(self.ioQueue, ^{
        NSData *imageData = UIImagePNGRepresentation(image);

        NSFileManager *fileManager = [NSFileManager new];
        if (![fileManager fileExistsAtPath:self.cacheDirectory]) {
            [fileManager createDirectoryAtPath:self.cacheDirectory
                   withIntermediateDirectories:YES
                                    attributes:nil
                                         error:NULL];
        }

        [fileManager createFileAtPath:[self cacheFilePathForURLString:URLString] contents:imageData attributes:nil];
    });
}

- (void)clearCache {
    dispatch_async(self.ioQueue, ^{
        [NSFileManager.defaultManager removeItemAtPath:self.cacheDirectory error:nil];
        [NSFileManager.defaultManager createDirectoryAtPath:self.cacheDirectory
                                withIntermediateDirectories:YES
                                                 attributes:nil
                                                      error:NULL];
    });
}

- (void)removeImageWithURLString:(NSString *)URLString {
    dispatch_async(self.ioQueue, ^{
        BOOL removed = [NSFileManager.defaultManager removeItemAtPath:[self cacheFilePathForURLString:URLString] error:nil];
        if (!removed) {
            NSLog(@"Warning: There was no file to remove at path: %@", URLString);
        }
    });
}

#pragma mark - Helpers

- (NSString *)cacheFilePathForURLString:(NSString *)URLString {
    return [self.cacheDirectory stringByAppendingPathComponent:[self cachedFileNameForURLString:URLString]];
}

- (NSString *)cachedFileNameForURLString:(NSString *)URLString {
    const char *str = URLString.UTF8String;
    if (str == NULL) {
        str = "";
    }
    unsigned char r[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)strlen(str), r);
    NSString *filename = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                                                    r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10],
                                                    r[11], r[12], r[13], r[14], r[15]];

    return filename;
}

@end
