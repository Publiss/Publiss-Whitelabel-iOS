//
//  PUBCellView+Document.m
//  Publiss
//
//  Created by Denis Andrasec on 06.05.14.
//  Copyright (c) 2014 Publiss GmbH. All rights reserved.
//

#import "PUBCellView+Document.h"
#import "PUBDocument+Helper.h"
#import "PUBConstants.h"

@implementation PUBCellView (Document)

- (void)setupForDocument:(PUBDocument *)document {
    self.deleteButton.hidden = YES;
    [self setBadgeViewHidden:YES animated:NO];
    self.namedBadgeView.hidden = YES;
    self.coverImage.hidden = NO;
    
    switch (document.state) {
        case PUBDocumentStateOnline:
            [self documentOnline];
            break;
        case PUBDocumentStateUpdated:
            [self documentUpdated];
            break;
        case PUBDocumentStateDownloaded:
            [self documentDownloaded];
            break;
        case PUBDocumentStateLoading:
            [self documentLoadingForDocument:document];
            break;
        case PUBDocumentPurchased:
            [self documentPurchased];
            break;
    }
    
    [self.label setLineSpacedText:document.title];
}

- (void)documentOnline {
    [self setBadgeViewHidden:NO animated:NO];
    self.progressView.hidden = YES;
}

- (void)documentUpdated {
    self.namedBadgeView.hidden = NO;
    [self.namedBadgeView setBadgeText:PUBLocalize(@"UPDATE")];
    self.progressView.hidden = YES;
    
    [self.namedBadgeView setNeedsDisplay];
}

- (void)documentDownloaded {
    self.progressView.progress = 0.f;
    self.progressView.hidden = YES;
}

- (void)documentLoadingForDocument:(PUBDocument *)document {
    self.progressView.hidden = NO;
    self.progressView.progress = document.downloadProgress;
}

- (void)documentPurchased {
    self.namedBadgeView.hidden = NO;
    [self.namedBadgeView setBadgeText:PUBLocalize(@"PURCHASED")];
    [self setBadgeViewHidden:NO animated:NO];
    self.progressView.hidden = YES;
}


@end
