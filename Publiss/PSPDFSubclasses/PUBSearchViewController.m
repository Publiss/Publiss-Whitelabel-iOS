//
//  PUBSearchViewController.m
//  Publiss
//
//  Copyright (c) 2014 Publiss GmbH. All rights reserved.
//

#import "PUBSearchViewController.h"
#import "PSPDFKit.h"
#import "PUBConstants.h"

@implementation PUBSearchViewController

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - NSObject

- (id)initWithDocument:(PSPDFDocument *)document delegate:(id<PSPDFSearchViewControllerDelegate>)delegate {
    if (self = [super initWithDocument:document delegate:delegate]) {
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(remoteObjectDidChangeNotification:) name:PUBDocumentFetcherUpdateNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Notifications

// Every time a remote object is downloaded, we need to restart the search.
- (void)remoteObjectDidChangeNotification:(NSNotification *)notification {
    PSPDFRemoteFileObject *remoteFileObject = notification.object;
    if (remoteFileObject.remoteContentProgress == 1.f) {
        [self restartSearch];
    }
}

@end
