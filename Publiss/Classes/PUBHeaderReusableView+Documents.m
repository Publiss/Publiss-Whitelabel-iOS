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

@implementation PUBHeaderReusableView (Documents)

- (void)setupWithDocuments:(NSArray *)documents {
    PUBDocument *document = documents.firstObject;
    
    if (document && [document isKindOfClass:[PUBDocument class]]) {
        NSURL *featuredImageUrl = [PUBDocumentFetcher.sharedFetcher featuredImageForPublishedDocument:document.publishedID];
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:featuredImageUrl];
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        
        __weak typeof(self) welf = self;
        [self.imageView setImageWithURLRequest:urlRequest
                              placeholderImage:nil
                                       success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                           __strong PUBHeaderReusableView *stelf = welf;
                                           //[stelf animateImageWhenLoaded:stelf.imageView];
                                           stelf.imageView.image = image;
                                       } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                           
                                       }];
    }
}

- (void)animateImageWhenLoaded:(UIImageView *)imageView {
    imageView.alpha = 0.0;
    imageView.transform = CGAffineTransformMakeScale(1.2, 1.2);
    
    [UIView animateWithDuration:0.33 animations:^{
        imageView.alpha = 1.0;
        imageView.transform = CGAffineTransformIdentity;
    }];
}

@end
