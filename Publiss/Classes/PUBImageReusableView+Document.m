//
//  PUBImageReusableView+Document.m
//  Publiss
//
//  Created by Denis Andrasec on 14.10.14.
//  Copyright (c) 2014 Publiss GmbH. All rights reserved.
//

#import "PUBImageReusableView+Document.h"
#import "PUBDocument+Helper.h"
#import "PUBDocumentFetcher.h"
#import "UIImageView+AFNetworking.h"

@implementation PUBImageReusableView (Document)

- (void)setupWithDocument:(PUBDocument *)document {
    NSURL *featuredImageUrl = [PUBDocumentFetcher.sharedFetcher featuredImageForPublishedDocument:document.publishedID];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:featuredImageUrl];
    
    __weak typeof(self) welf = self;
    [self.imageView setImageWithURLRequest:urlRequest
                                  placeholderImage:nil
                                           success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                               welf.imageView.image = image;
                                           } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                               
                                           }];
}

@end
