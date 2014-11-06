//
//  PUBPDFViewController.m
//  Publiss
//
//  Copyright (c) 2014 Publiss GmbH. All rights reserved.
//

#import "PUBPDFViewController.h"
#import "PUBDocument.h"
#import "UIColor+PUBDesign.h"
#import "PUBDocument+Helper.h"
#import "PUBDocumentFetcher.h"
#import "PUBPDFDocument.h"
#import "PUBPageView.h"
#import "PUBSearchViewController.h"
#import "JDStatusBarNotification.h"
#import "PUBThumbnailGridViewCell.h"
#import "PUBKioskViewController.h"
#import "PUBLinkAnnotationView.h"
#import "PSPDFSpeechController.h"
#import "PUBConstants.h"

@interface PUBPDFViewController ()
@property (nonatomic, strong) NSDictionary *documentProgress;
@property (nonatomic, strong) JDStatusBarView *barView;
@property (nonatomic, assign) BOOL downloadFinished;
@property (nonatomic, assign) BOOL initiatedDownload;
@property (nonatomic, assign) BOOL initallyHiddenStatusBar;
@end

@implementation PUBPDFViewController

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - PSPDFViewController

- (instancetype)initWithDocument:(PSPDFDocument *)document configuration:(PSPDFConfiguration *)configuration {
    self = [super initWithDocument:document configuration:[configuration configurationUpdatedWithBuilder:^(PSPDFConfigurationBuilder *builder) {
         builder.backgroundColor = UIColor.blackColor;
        
        // Customize PSPDFKit defaults.
        [builder overrideClass:PSPDFLinkAnnotationView.class withClass:PUBLinkAnnotationView.class];
        [builder overrideClass:PSPDFPageView.class withClass:PUBPageView.class];
        [builder overrideClass:PSPDFSearchViewController.class withClass:PUBSearchViewController.class];
        
        // Appearance only needs to be set up once.
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            [[PSPDFTextSelectionView appearance] setSelectionColor:UIColor.publissPrimaryColor];
        });
        
        // HUD style
        
        builder.allowToolbarTitleChange = NO;
        
        builder.shouldShowHUDOnViewWillAppear = NO;
        builder.shouldHideNavigationBarWithHUD = YES;
        builder.shouldHideStatusBarWithHUD = YES;
        builder.backgroundColor = [UIColor blackColor];
        
        builder.allowBackgroundSaving = YES;
        builder.renderAnimationEnabled = NO; // Doesn't look good with progressive download.
        builder.pageTransition = PSPDFPageTransitionCurl;
        builder.renderingMode = PSPDFPageRenderingModeThumbnailThenFullPage;
        builder.thumbnailBarMode = PSPDFThumbnailBarModeScrollable;
        builder.pageMode = PSPDFPageModeAutomatic;
    }]];
    
    // setup Speechsynthesizer so its slower
    PSPDFSpeechController *speechController = [PSPDFKit sharedInstance].speechSynthesizer;
    speechController.speakRate = 0.15f;
    
    self.documentProgress = [NSDictionary dictionary];
    self.downloadFinished = NO;
    self.initiatedDownload = NO;
    self.navigationItem.title = PUBIsiPad() ? document.title : nil;
    
    self.thumbnailController.thumbnailCellClass = PUBThumbnailGridViewCell.class;
    
    // Toolbar configuration
    if (PUBIsiPad()) {
        self.rightBarButtonItems = @[self.annotationButtonItem, self.activityButtonItem, self.searchButtonItem, self.outlineButtonItem, self.viewModeButtonItem];
    } else {
        self.rightBarButtonItems = @[self.activityButtonItem, self.searchButtonItem, self.outlineButtonItem, self.viewModeButtonItem];
    }
    self.outlineButtonItem.availableControllerOptions = [NSOrderedSet orderedSetWithObjects:@(PSPDFOutlineBarButtonItemOptionOutline), @(PSPDFOutlineBarButtonItemOptionBookmarks), nil];
    self.activityButtonItem.applicationActivities = @[PSPDFActivityTypeGoToPage];
    self.activityButtonItem.excludedActivityTypes = @[UIActivityTypeCopyToPasteboard, UIActivityTypeAssignToContact];
    
    // Restore view state.
    if (self.pubDocument) {
        [self setViewState:self.pubDocument.lastViewState];
    }

    self.leftBarButtonItems = @[[[UIBarButtonItem alloc] initWithTitle:PUBLocalize(@"Close")
                                                                 style:UIBarButtonItemStyleDone
                                                                target:self
                                                                action:@selector(close:)]];
    
    [PUBDocumentFetcher.sharedFetcher checkIfDocumentIsUnpublished:self.pubDocument competionHandler:^(BOOL unpublished) {
        if (unpublished == YES && self.pubDocument.state != PUBDocumentStateDownloaded) {
            self.navigationController.navigationBar.hidden = NO;
            self.kioskViewController.shouldRetrieveDocuments = YES;
            [self close:nil];
        } else {
            // Ensure all pages are downloaded.
            [self prefetchAllPages];
            
            // self.initiatedDownload will be YES if any page is missing
            if (self.initiatedDownload) {
                self.pubDocument.state = PUBDocumentStateLoading;
                [self showLoadingNotification];
            }
        }
    }];
    
    return self;
}

- (void)close:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUserInterface];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self hideStatusBarInJustTheReightWay];
    
    NSNotificationCenter *dnc = NSNotificationCenter.defaultCenter;
    [dnc addObserver:self selector:@selector(pageViewDidLoad:) name:PSPDFViewControllerDidLoadPageViewNotification object:nil];
    [dnc addObserver:self selector:@selector(documentFetcherDidUpdateNotification:) name:PUBDocumentFetcherUpdateNotification object:nil];
}

- (BOOL)prefersStatusBarHidden {
    return self.initallyHiddenStatusBar ? YES : [super prefersStatusBarHidden];
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return self.initallyHiddenStatusBar ? UIStatusBarAnimationFade : [super preferredStatusBarUpdateAnimation];
}

- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)hideStatusBarInJustTheReightWay {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.initallyHiddenStatusBar = YES;
        [self setNeedsStatusBarAppearanceUpdate];
        self.initallyHiddenStatusBar = NO;
        [self setHUDVisible:YES animated:NO];
        [self setHUDVisible:NO animated:NO];
    });
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (self.pubDocument) {
        self.pubDocument.lastViewState = self.viewState;
    }
    [JDStatusBarNotification dismissAnimated:YES];
    
    NSNotificationCenter *dnc = NSNotificationCenter.defaultCenter;
    [dnc removeObserver:self name:PSPDFViewControllerDidLoadPageViewNotification object:nil];
    [dnc removeObserver:self name:PSPDFViewControllerDidLoadPageViewNotification object:nil];
}

- (void)setupUserInterface {
    self.navigationController.toolbar.tintColor = UIColor.publissPrimaryColor;
    self.navigationController.navigationBar.tintColor = UIColor.publissSecondaryColor;
    self.navigationController.navigationBar.barStyle = UIStatusBarStyleLightContent;
    self.navigationController.navigationBar.barTintColor = UIColor.publissPrimaryColor;
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:UIColor.publissSecondaryColor};
}

// Blurring of gallery
//- (void)viewDidLoad {
//    [super viewDidLoad];
//
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        [[PSPDFGalleryEmbeddedBackgroundView appearance] setBlurEnabledObject:@YES];
//        [[PSPDFGalleryFullscreenBackgroundView appearance] setBlurEnabledObject:@YES];
//    });
//}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Private

- (void)prefetchAllPages {
    [PUBDocumentFetcher.sharedFetcher fetchMetadataForDocument:self.pubDocument completionBlock:^(PUBDocument *document, NSURL *XFDFURL, NSError *error) {
        [(PUBPDFDocument *)self.document loadAnnotationsFromXFDF];
    }];

    for (NSUInteger page = 0; page < self.document.pageCount; page++) {
        [self fetchFileIfMissingForPage:page enqueueAtFront:NO];
    }
}

- (PUBDocument *)pubDocument {
    return [PUBSafeCast(self.document, PUBPDFDocument.class) pubDocument];
}

- (void)fetchFileIfMissingForPage:(NSUInteger)page enqueueAtFront:(BOOL)enqueueAtFront {
    PSPDFDocumentProvider *documentProvider = [self.document documentProviderForPage:page];
    if (![NSFileManager.defaultManager fileExistsAtPath:documentProvider.fileURL.path]) {
        __weak typeof(self)weakSelf = self;
        self.initiatedDownload = YES;
        [PUBDocumentFetcher.sharedFetcher fetchDocument:self.pubDocument page:page enqueueAtFront:enqueueAtFront completionHandler:^(NSString *productID, NSUInteger pageIndex) {
            [weakSelf updatePage:page animated:YES];
            if (self.HUDView.thumbnailBar.visibleCells.count) {
                for (PSPDFThumbnailGridViewCell *cell in self.HUDView.thumbnailBar.visibleCells) {
                    [cell updateCell];
                }
            }
        }];
    } else {
        // needed for correct progress calculation
        [PUBDocumentFetcher.sharedFetcher setPageAlreadyExsists:self.pubDocument page:page];
    }
}

- (void)updateProgress {
    NSInteger pagesDoneCount = 0;
    
    for (NSNumber *progress in self.documentProgress[@"pageProgress"]) {
        if (progress.floatValue >= .99f) {
            pagesDoneCount++;
        }
    }
    
    if ([JDStatusBarNotification isVisible]) {
        self.barView.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Page %tu of %tu done.", nil), self.document.pageCount < pagesDoneCount + 1 ? self.document.pageCount : (NSUInteger) (pagesDoneCount + 1), self.document.pageCount];
        [JDStatusBarNotification showProgress:[self.documentProgress[@"totalProgress"] floatValue]];
        if ([self.documentProgress[@"totalProgress"] floatValue] >= .99999999999f) {
            [JDStatusBarNotification dismissAfter:1];
            self.downloadFinished = YES;
        }
    }
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Notifications

- (void)pageViewDidLoad:(NSNotification *)notification {
    // Check if the file exists, load if it doesn't.
    PSPDFPageView *pageView = notification.object;
    [self fetchFileIfMissingForPage:pageView.page enqueueAtFront:YES];
}

- (void)documentFetcherDidUpdateNotification:(NSNotification *)notification {
    if ([notification.userInfo[((PUBDocument *)self.document).productID] count] && !self.downloadFinished) {
        self.documentProgress = notification.userInfo[((PUBDocument *)self.document).productID];
        [self updateProgress];
    }
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Timer



- (void)showLoadingNotification {
    //customizing progress view
    [JDStatusBarNotification addStyleNamed:@"publiss"
                                   prepare:^JDStatusBarStyle*(JDStatusBarStyle *style) {
                                       
                                       // main properties
                                       style.barColor = [UIColor blackColor];
                                       style.textColor = [UIColor whiteColor];
                                       
                                       // advanced properties
                                       style.animationType = JDStatusBarAnimationTypeFade;
                                       
                                       // progress bar
                                       style.progressBarColor = [UIColor whiteColor];
                                       style.progressBarHeight = 1;
                                       style.progressBarPosition = JDStatusBarProgressBarPositionBottom;
                                       
                                       return style;
                                   }];
    
    self.barView = [JDStatusBarNotification showWithStatus:NSLocalizedString(@"PDF is being downloaded ...", nil) styleName:@"publiss"];
}



@end
