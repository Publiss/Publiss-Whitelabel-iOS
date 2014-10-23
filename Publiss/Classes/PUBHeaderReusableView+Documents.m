//
//  PUBHeaderReusableView+Documents.m
//  Publiss
//
//  Created by Denis Andrasec on 15.10.14.
//  Copyright (c) 2014 Publiss GmbH. All rights reserved.
//

#import "PUBHeaderReusableView+Documents.h"
#import "PUBDocument+Helper.h"
#import "UIIMageView+AFNetworking.h"
#import "PUBDocumentFetcher.h"
#import "PUBThumbnailImageCache.h"

@implementation PUBHeaderReusableView (Documents)

- (void)setupWithDocuments:(NSArray *)documents {
    PUBDocument *document = documents.firstObject;
    
    if (document && [document isKindOfClass:[PUBDocument class]]) {
        NSURL *featuredImageUrl = [PUBDocumentFetcher.sharedFetcher featuredImageForPublishedDocument:(NSUInteger)document.publishedID];
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:featuredImageUrl];
        UIImage *featuredImage = [PUBThumbnailImageCache.sharedInstance thumbnailImageWithURLString:featuredImageUrl.absoluteString];
        
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.cloudImageView.hidden = document.state == PUBDocumentPurchased || document.state == PUBDocumentStateDownloaded;
        
        if (featuredImage) {
            self.imageView.image = featuredImage;
        }
        else {
            __weak typeof(self) welf = self;
            [NSURLConnection sendAsynchronousRequest:urlRequest
                                               queue:[NSOperationQueue mainQueue]
                                   completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                                       if (!connectionError) {
                                           UIImage *image = [[UIImage alloc] initWithData:data];
                                           welf.imageView.image = image;
                                           [PUBThumbnailImageCache.sharedInstance setImage:image
                                                                              forURLString:featuredImageUrl.absoluteString];
                                       }
                                   }];
            
        }
    }
}

- (void)animateImageWhenLoaded:(UIImageView *)imageView {
    imageView.alpha = 0.0;
    imageView.transform = CGAffineTransformMakeScale(1.2f, 1.2f);
    
    [UIView animateWithDuration:0.33 animations:^{
        imageView.alpha = 1.0;
        imageView.transform = CGAffineTransformIdentity;
    }];
}

@end
