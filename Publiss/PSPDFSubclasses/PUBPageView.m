//
//  PUBPageView.m
//  Publiss
//
//  Copyright (c) 2014 Publiss GmbH. All rights reserved.
//

#import "PUBPageView.h"
#import "PUBDocumentFetcher.h"
#import "PUBPDFDocument.h"
#import "PUBDocument.h"
#import "PUBProgressView.h"
#import "UIImageView+AFNetworking.h"
#import "PUBConstants.h"

@interface PSPDFDocumentProvider (PUBPrivateAccess)
- (BOOL)localFileIsMissing;
@end

@interface PUBPageView ()
@property (nonatomic, strong) PUBProgressView *activityView;
@property (nonatomic, assign) BOOL isDownloadingPreviewImage;
@property (nonatomic, strong) UILabel *loadingLabel;
@end

@implementation PUBPageView

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - NSObject

- (id)initWithFrame:(CGRect)frame delegate:(id <PSPDFPageViewDelegate>)delegate {
    if (self = [super initWithFrame:frame delegate:delegate]) {
        self.clipsToBounds = YES;
        _activityView = [[PUBProgressView alloc] initWithFrame:self.bounds];
        [self addSubview:_activityView];

        //_loadingLabel = [UILabel new];
        //[self addSubview:_loadingLabel];
    
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(documentFetcherDidUpdateNotification:) name:PUBDocumentFetcherUpdateNotification object:nil];

    }
    return self;
}

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UIView

- (void)layoutSubviews {
    [super layoutSubviews];
        
    [self bringSubviewToFront:self.activityView];
    self.activityView.frame = self.bounds;
//    self.activityView.center = self.center;
    [self updateContentLoadingIndicatorAnimated:YES];

//    [self bringSubviewToFront:self.loadingLabel];
//    [self.loadingLabel sizeToFit];
//    self.loadingLabel.center = self.center;
//    NSLog(@"page view: %@", self);
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - PSPDFPageView

- (void)displayPage:(NSUInteger)page pageRect:(CGRect)pageRect scale:(CGFloat)scale delayPageAnnotations:(BOOL)delayPageAnnotations presentationContext:(id <PSPDFPresentationContext>)presentationContext {
    [super displayPage:page pageRect:pageRect scale:scale delayPageAnnotations:delayPageAnnotations presentationContext:presentationContext];

    // Prepare progress
    [self.activityView setProgress:0.f animated:NO];
    [self updateContentLoadingIndicatorAnimated:NO];

    // Load image
    [self downloadPreviewImage];
}

- (void)prepareForReuse {
    [super prepareForReuse];

    [self.contentView cancelImageRequestOperation];
    self.isDownloadingPreviewImage = NO;
}

- (void)updateView {
    [super updateView];
    
    [self updateContentLoadingIndicatorAnimated:YES];
}

// We already limit the menu entries, so don't move into a submenu.
- (BOOL)shouldMoveStyleMenuEntriesIntoSubmenu {
    return NO;
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Private

- (BOOL)requiresFileDownload {
    PSPDFDocumentProvider *documentProvider = [self.document documentProviderForPage:self.page];
    return documentProvider.localFileIsMissing;
}

- (void)downloadPreviewImage {
    if (self.requiresFileDownload && !self.isDownloadingPreviewImage) {
        self.isDownloadingPreviewImage = YES;
        PUBDocument *pubDocument = ((PUBPDFDocument *)self.document).pubDocument;
        NSURL *imageURL = [PUBDocumentFetcher.sharedFetcher imageForDocumentOptimized:pubDocument page:self.page];
        NSMutableURLRequest *imageRequest = [NSMutableURLRequest requestWithURL:imageURL];
        [imageRequest addValue:@"image/*" forHTTPHeaderField:@"Accept"];
        __weak __typeof(self)weakSelf = self;
        PUBLogVerbose(@"Downloading image... %@", imageRequest.URL);
        [self.contentView setImageWithURLRequest:imageRequest placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
            PUBLogVerbose(@"Image loading success: %@.", image);

            __typeof(self)strongSelf = weakSelf;
            if (strongSelf.requiresFileDownload) {
                strongSelf.contentView.image = image;
            }
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
            PUBLogError(@"Image loading failed: %@", error);
        }];
    }
}

- (void)updateContentLoadingIndicatorAnimated:(BOOL)animated {
    // Get status for current page
    if (self.requiresFileDownload) {
        PUBDocument *pubDocument = ((PUBPDFDocument *)self.document).pubDocument;
        PSPDFRemoteFileObject *remoteObject = [PUBDocumentFetcher.sharedFetcher remoteContentObjectForDocument:pubDocument page:self.page];

        self.activityView.hidden = NO;
        [self.activityView setProgress:(float)remoteObject.remoteContentProgress animated:animated];

        //self.loadingLabel.hidden = remoteObject == nil;
        //self.loadingLabel.text = [NSString stringWithFormat:@"%@", remoteObject.description];
        [self.loadingLabel sizeToFit];
    } else {
        [self.activityView setProgress:1.f animated:animated];

        //[self.contentView cancelImageRequestOperation];
    }
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Notifications

- (void)documentFetcherDidUpdateNotification:(NSNotification *)notification {
    [self updateContentLoadingIndicatorAnimated:YES];
}

@end
