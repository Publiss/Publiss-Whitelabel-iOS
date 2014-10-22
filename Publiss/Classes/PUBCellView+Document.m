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
    self.badgeView.hidden = YES;
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
}

- (void)documentOnline {
    self.badgeView.hidden = NO;
    self.progressView.hidden = YES;
}

- (void)documentUpdated {
    self.namedBadgeView.hidden = NO;
    [self.namedBadgeView setBadgeText:PUBLocalize(@"UPDATE")];
    self.progressView.hidden = YES;
}

- (void)documentDownloaded {
    self.badgeView.hidden = YES;
    self.namedBadgeView.hidden = YES;
    self.progressView.progress = 0.f;
    self.progressView.hidden = YES;
}

- (void)documentLoadingForDocument:(PUBDocument *)document {
    self.badgeView.hidden = YES;
    self.namedBadgeView.hidden = YES;
    self.progressView.hidden = NO;
    self.progressView.progress = document.downloadProgress;
}

- (void)documentPurchased {
    self.badgeView.hidden = YES;
    self.namedBadgeView.hidden = NO;
    [self.namedBadgeView setBadgeText:PUBLocalize(@"PURCHASED")];
    self.progressView.hidden = YES;
}


@end
