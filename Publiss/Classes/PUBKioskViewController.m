//
//  PUBKioskViewController.m
//  Publiss
//
//  Copyright (c) 2014 Publiss GmbH. All rights reserved.
//

#import "PUBKioskViewController.h"
#import "PUBPreviewViewController.h"
#import "PUBDocument+Helper.h"
#import "PUBCellView+Document.h"
#import "PUBCommunication.h"
#import "PUBDocumentFetcher.h"
#import "UIColor+PUBDesign.h"
#import "PUBScaleTransition.h"
#import "PUBThumbnailImageCache.h"
#import "PUBPDFViewController.h"
#import "PUBiPhonePreviewViewController.h"
#import "UIImageView+AFNetworking.h"
#import "PUBPDFDocument.h"
#import "IAPController.h"
#import "PUBHTTPRequestManager.h"
#import <REMenu/REMenu.h>
#import "JDStatusBarNotification.h"
#import "UIImage+PUBTinting.h"
#import "PSPDFWebViewController.h"
#import "PUBBugFixFlowLayout.h"
#import "PUBCoreDataStack.h"
#import "PUBConstants.h"
#import <PublissCore.h>
#import "PUBKioskLayout.h"
#import "PUBHeaderReusableView+Documents.h"
#import "UIActionSheet+Blocks.h"

#import "PUBTransitioningDelegate.h"

@interface PUBKioskViewController () <PSPDFViewControllerDelegate, UIAlertViewDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate> {
    NSUInteger _animationCellIndex;
    BOOL _animationDoubleWithPageCurl;
    BOOL _animateViewWillAppearWithFade;
}

@property (nonatomic, strong) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) PUBKioskLayout *kioskLayout;

@property (nonatomic, strong) UIView *dimView;
@property (nonatomic, strong) UIActivityIndicatorView *spinner;
@property (nonatomic, strong) REMenu *menu;
@property (nonatomic, strong) UIImageView *documentView;

@property (nonatomic, assign) BOOL isOpening;

@property (nonatomic, copy) NSArray *featuredDocuments;
@property (nonatomic, copy) NSArray *publishedDocuments;

@property (nonatomic, strong) NSMutableDictionary *coverImageDictionary;
@property (nonatomic, strong) NSDictionary *indexPathsForDocuments;

@property (nonatomic, strong) PUBDocument *lastOpenedDocument;
@property (nonatomic, strong) NSTimer *pageTracker;

@property (nonatomic, strong) PUBTransitioningDelegate *transitioningDelegate;

@end

#define LINE_HEIGHT 30.f

@implementation PUBKioskViewController {
    NSNumber *trackedPageTime;
}

#pragma mark - UIViewController

+ (PUBKioskViewController *)kioskViewController {
    return [[UIStoryboard storyboardWithName:@"PUBKiosk" bundle:nil] instantiateInitialViewController];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UIApplication.sharedApplication.statusBarStyle = UIStatusBarStyleLightContent;
    self.view.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:1.0f];
    
    self.coverImageDictionary = [NSMutableDictionary dictionary];
    
    [self setupNavigationItems];
    [self setupCollectionView];
    [self setupMenu];

    self.dimView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.dimView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.dimView.userInteractionEnabled = NO;
    self.dimView.backgroundColor = [UIColor blackColor];
    self.dimView.alpha = 0.0f;
    self.dimView.hidden = YES;
    [self.view addSubview:self.dimView];
    
    self.spinner = [UIActivityIndicatorView new];
    self.spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    self.spinner.color = [UIColor publissPrimaryColor];
    self.spinner.frame = CGRectMake(self.view.center.x - 10.f, self.view.center.y - 10.f, 20.f, 20.f);
    self.spinner.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    [self.collectionView addSubview:self.spinner];
    self.spinner.hidden = YES;
    
    [JDStatusBarNotification addStyleNamed:PurchasedMenuStyle
                                   prepare:^JDStatusBarStyle *(JDStatusBarStyle *style) {
                                       style.barColor = [UIColor whiteColor];
                                       style.textColor = [UIColor publissPrimaryColor];
                                       style.animationType = JDStatusBarAnimationTypeBounce;
                                       style.font = [UIFont boldSystemFontOfSize:13.f];
                                       return style;
                                   }];
    
    [self refreshDocumentsWithActivityViewAnimated:YES];
    
    self.transitioningDelegate = [PUBTransitioningDelegate new];
}

- (void)setupCollectionView {
    self.collectionView.backgroundColor = [[UIColor colorWithPatternImage:[UIImage imageNamed:@"KioskShelveBackground"]] colorWithAlphaComponent:1.0f];
    self.kioskLayout = [[PUBKioskLayout alloc] init];
    self.collectionView.collectionViewLayout = self.kioskLayout;
    [self.collectionView.collectionViewLayout invalidateLayout];
    [self.collectionView registerClass:[PUBHeaderReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"PUBHeaderReusableView"];
    
    UILongPressGestureRecognizer *longpressGesture = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(handleLongPressgesture:)];
    longpressGesture.delegate = self;
    [self.collectionView addGestureRecognizer:longpressGesture];
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
}

- (void)showMenu:(id)sender {
    if (!self.menu.isOpen) {
        [self.menu showFromNavigationController:self.navigationController];
    }
    else {
        [self.menu close];
    }
}

- (void)setupMenu {
    UIBarButtonItem *menuItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu_icon"]
                                                                 style:UIBarButtonItemStylePlain
                                                                target:self
                                                                action:@selector(showMenu:)];
    self.navigationItem.leftBarButtonItems = @[menuItem];
    
    REMenuItem *reloadItem = [[REMenuItem alloc] initWithTitle:PUBLocalize(@"Reload")
                                                      subtitle:nil
                                                         image:[[UIImage imageNamed:@"refresh"] imageTintedWithColor:UIApplication.sharedApplication.delegate.window.tintColor fraction:0.f]
                                              highlightedImage:nil
                                                        action:^(REMenuItem *item) {
                                                            [self refreshDocumentsWithActivityViewAnimated:YES];
                                                        }];
    
    
    REMenuItem *visitSiteItem = [[REMenuItem alloc] initWithTitle:PUBLocalize(@"Visit Publiss Website")
                                                         subtitle:nil
                                                            image:[[UIImage imageNamed:@"web"] imageTintedWithColor:UIApplication.sharedApplication.delegate.window.tintColor fraction:0.f]
                                                 highlightedImage:nil
                                                           action:^(REMenuItem *item) {
                                                               [self visitPublissSite];
                                                           }];
    
    
    REMenuItem *aboutItem = [[REMenuItem alloc] initWithTitle:PUBLocalize(@"About Publiss")
                                                     subtitle:nil
                                                        image:[[UIImage imageNamed:@"about"] imageTintedWithColor:UIApplication.sharedApplication.delegate.window.tintColor fraction:0.f]
                                             highlightedImage:nil
                                                       action:^(REMenuItem *item) {
                                                           [self showAbout];
                                                       }];
    
    NSMutableArray *menuItems = @[
                                  reloadItem,
                                  visitSiteItem,
                                  aboutItem,
                                  ].mutableCopy;
    
    if (PUBConfig.sharedConfig.inAppPurchaseActive) {
        REMenuItem *restoreItem = [[REMenuItem alloc] initWithTitle:PUBLocalize(@"Restore Purchases")
                                                           subtitle:nil
                                                              image:[[UIImage imageNamed:@"restore"] imageTintedWithColor:UIApplication.sharedApplication.delegate.window.tintColor fraction:0.f]
                                                   highlightedImage:nil
                                                             action:^(REMenuItem *item) {
                                                                 [self restorePurchases];
                                                             }];
        [menuItems insertObject:restoreItem atIndex:1];
        
#ifdef DEBUG
        REMenuItem *clearItem = [[REMenuItem alloc] initWithTitle:@"(DEBUG) Clear"
                                                         subtitle:nil
                                                            image:nil
                                                 highlightedImage:nil
                                                           action:^(REMenuItem *item) {
                                                               [self clearPurchases];
                                                           }];
        
        [menuItems addObject:clearItem];
#endif
    }
    
    self.menu = [[REMenu alloc] initWithItems:menuItems];
    
    self.menu.textAlignment = NSTextAlignmentLeft;
    self.menu.bounce = YES;
    self.menu.bounceAnimationDuration = .1f;
    self.menu.animationDuration = .29f;
    self.menu.separatorHeight = 1.f;
    self.menu.separatorColor = self.menu.highlightedSeparatorColor = [[UIColor blackColor] colorWithAlphaComponent:.1f];
    self.menu.borderWidth = 0.0f;
    self.menu.textColor = UIApplication.sharedApplication.delegate.window.tintColor;
    self.menu.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16.f];
    self.menu.textShadowOffset = CGSizeZero;
    self.menu.shadowColor = [UIColor clearColor];
    self.menu.highlightedBackgroundColor = [UIColor colorWithWhite:1.f alpha:.3f];
    self.menu.highlightedTextShadowColor = [UIColor clearColor];
    self.menu.highlightedTextColor = UIApplication.sharedApplication.delegate.window.tintColor;
    self.menu.liveBlur = YES;
    self.menu.liveBlurBackgroundStyle = REMenuLiveBackgroundStyleLight;
    self.menu.textOffset = CGSizeMake(66.f, 0.f);
    self.menu.imageOffset = CGSizeMake(18.f, 0.f);
    self.menu.backgroundColor = UIColor.clearColor;
    self.menu.liveBlurTintColor = [UIColor  publissPrimaryColor];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    NSNotificationCenter *dnc = NSNotificationCenter.defaultCenter;
    [dnc addObserver:self selector:@selector(enableUIInteraction:) name:PUBEnableUIInteractionNotification object:nil];
    [dnc addObserver:self selector:@selector(trackPage) name:UIApplicationWillResignActiveNotification object:nil];
    [dnc addObserver:self selector:@selector(documentFetcherDidUpdate:) name:PUBDocumentFetcherUpdateNotification object:NULL];
    [dnc addObserver:self selector:@selector(documentFetcherDidFinish:) name:PUBDocumentDownloadNotification object:NULL];
    [dnc addObserver:self selector:@selector(documentPurchased:) name:PUBDocumentPurchaseFinishedNotification object:nil];
    [dnc addObserver:self selector:@selector(refreshDocumentsWithActivityViewAnimated:) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [UIView animateWithDuration:0.25f animations:^{
        self.navigationController.navigationBar.alpha = 1.f;
    }];
    [UIApplication.sharedApplication setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    [UIApplication.sharedApplication setStatusBarStyle:UIStatusBarStyleLightContent animated:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // Animate back to grid cell?
    if (self.documentView) {
        [self.collectionView layoutSubviews]; // ensure cells are laid out
        
        // Convert the coordinates into view coordinate system.
        // We can't remember those, because the device might has been rotated.
        PUBCellView *cell = (PUBCellView *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:_animationCellIndex inSection:0]];
        [cell setupForDocument:self.lastOpenedDocument];
        CGRect relativeCellRect = [cell.coverImage convertRect:cell.coverImage.bounds toView:self.view];
        
        self.documentView.frame = [self magazinePageCoordinatesWithDoublePageCurl:_animationDoubleWithPageCurl && UIInterfaceOrientationIsLandscape(UIApplication.sharedApplication.statusBarOrientation) onFirstPage:(self.lastOpenedDocument.lastViewState.page == 0)];
        
        // Update image for a nicer animation (get the correct page)
        UIImage *coverImage = [self imageForDocument:self.lastOpenedDocument];
        if (coverImage) self.documentView.image = coverImage;
        
        // Start animation!
        [UIView animateWithDuration:0.3f delay:0.f options:0 animations:^{
            self.documentView.frame = relativeCellRect;
            [self.documentView.subviews.lastObject setAlpha:0.f];
            self.dimView.alpha = 0.0f;
        } completion:^(BOOL finished) {
            cell.hidden = NO;
            [UIView transitionWithView:self.documentView duration:0.25f options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
                self.documentView.alpha = 0.0f;
            } completion:^(BOOL finish) {
                [self.documentView removeFromSuperview];
                self.documentView = nil;
                self.dimView.hidden = YES;
                
                if (self.shouldRetrieveDocuments) {
                    self.shouldRetrieveDocuments = NO;
                    [self refreshDocumentsWithActivityViewAnimated:YES];
                }
            }];
        }];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

    NSNotificationCenter *dnc = NSNotificationCenter.defaultCenter;
    [dnc removeObserver:self name:PUBEnableUIInteractionNotification object:nil];
    [dnc removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [dnc removeObserver:self name:PUBDocumentFetcherUpdateNotification object:nil];
    [dnc removeObserver:self name:PUBDocumentDownloadNotification object:nil];
    [dnc removeObserver:self name:PUBDocumentPurchaseFinishedNotification object:nil];
    [dnc removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    
    if (self.pageTracker.isValid) {
        [self.pageTracker invalidate];
        self.pageTracker = nil;
    }
}

#pragma mark - Private

- (void)refreshDocumentsWithActivityViewAnimated:(BOOL)animated {    
    self.collectionView.userInteractionEnabled = NO;
    self.editButtonItem.enabled = NO;
    
    if (![self.spinner isAnimating] && animated) {
        [self.spinner startAnimating];
    }
    
    [PUBCommunication.sharedInstance fetchAndSaveDocuments:^{
        [PUBCoreDataStack.sharedCoreDataStack saveContext];
        self.publishedDocuments = [PUBDocument fetchAllSortedBy:SortOrder ascending:YES predicate:[NSPredicate predicateWithFormat:@"featured != YES"]];
        self.featuredDocuments = [PUBDocument fetchAllSortedBy:SortOrder ascending:YES predicate:[NSPredicate predicateWithFormat:@"featured == YES"]];
        
        self.kioskLayout.showsHeader = self.featuredDocuments.count > 0;
        
        [self.collectionView reloadData];
        self.collectionView.userInteractionEnabled = YES;
        self.editButtonItem.enabled = YES;
        [self.spinner stopAnimating];
    }];
}

#pragma mark - CollectionView DataSoure

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.publishedDocuments.count;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    PUBHeaderReusableView *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                                           withReuseIdentifier:@"PUBHeaderReusableView"
                                                                                                  forIndexPath:indexPath];
    [header setupWithDocuments:self.featuredDocuments];
    
    header.singleTapBlock = ^() {
        [self showPreviewForDocument:self.featuredDocuments.firstObject];
    };
    
    header.longPressBlock = ^() {
        
        PUBDocument *document = self.featuredDocuments.firstObject;
        
        if (document.state == PUBDocumentStateDownloaded) {
            [UIActionSheet showInView:self.view
                            withTitle:PUBLocalize(@"Do you want to remove the PDF for this document?")
                    cancelButtonTitle:PUBLocalize(@"Cancel")
               destructiveButtonTitle:PUBLocalize(@"Yes, remove PDF")
                    otherButtonTitles:nil
                             tapBlock:^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
                                 if (buttonIndex == actionSheet.destructiveButtonIndex) {
                                     [self removePdfForDocument:document];
                                 }
                             }];
        }
    };
    
    return header;
}



- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *const identifier = @"DocumentCell";
    PUBCellView *cell = (PUBCellView *)[collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    PUBDocument *document = (self.publishedDocuments)[indexPath.item];
    [cell setupForDocument:(PUBDocument *)document];
    [cell.deleteButton addTarget:self
                          action:@selector(deleteButtonClicked:)
                forControlEvents:UIControlEventTouchUpInside];
    
    // first look in cover image cache if there is already a preprocessed cover image
    NSURL *thumbnailURL = [PUBDocumentFetcher.sharedFetcher coverImageForDocument:document withSize:cell.bounds.size];
    UIImage *thumbnail = [PUBThumbnailImageCache.sharedInstance thumbnailImageWithURLString:thumbnailURL.absoluteString];
    NSString *cachedImageURL = [PUBThumbnailImageCache.sharedInstance cacheFilePathForURLString:thumbnailURL.absoluteString];
    
    (self.coverImageDictionary)[cachedImageURL] = document.title;
    
    if (thumbnail != nil && [document.title isEqualToString:[self.coverImageDictionary valueForKey:cachedImageURL]]) {
        cell.coverImage.image = thumbnail;
        [cell setNeedsLayout];
    } else {
        [cell.activityIndicator startAnimating];
        cell.coverImage.hidden = YES;
        cell.badgeView.hidden = YES;
        cell.namedBadgeView.hidden = YES;
        NSURLRequest *URLRequest = [NSURLRequest requestWithURL:thumbnailURL];
        
        __weak PUBCellView *weakCell = cell;
        __weak PUBDocument *weakDocument = document;
        [cell.coverImage setImageWithURLRequest:URLRequest
                               placeholderImage:nil
                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                            PUBCellView *strongCell = weakCell;
                                            PUBDocument *strongDocument = weakDocument;
                                            strongCell.coverImage.image = image;
                                            strongCell.coverImage.alpha = 0.f;
                                            strongCell.coverImage.hidden = NO;
                                            strongCell.namedBadgeView.hidden = YES;
                                            [strongCell setBadgeViewHidden:YES animated:NO];
                                            [strongCell.activityIndicator stopAnimating];
                                            [strongCell setNeedsLayout];
                                            
                                            // animate first magazin coverload with scale animation
                                            strongCell.coverImage.transform = CGAffineTransformMakeScale(.1f, .1f);
                                            [UIView animateWithDuration:.4f animations:^{
                                                strongCell.coverImage.alpha = 1.f;
                                                strongCell.coverImage.transform = CGAffineTransformIdentity;
                                            } completion:^(BOOL finished) {
                                                BOOL shouldHideBadgeView = (strongDocument.state == PUBDocumentStateUpdated || strongDocument.state == PUBDocumentPurchased);
                                                strongCell.namedBadgeView.hidden = !shouldHideBadgeView;
                                                [strongCell setBadgeViewHidden:shouldHideBadgeView animated:YES];
                                            }];
                                            
                                            
                                            [PUBThumbnailImageCache.sharedInstance setImage:image forURLString:thumbnailURL.absoluteString];
                                        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                            PUBCellView *strongCell = weakCell;
                                            strongCell.coverImage.hidden = NO;
                                            [strongCell.activityIndicator stopAnimating];
                                            PUBLogWarning(@"Failed to get image: %@", error);
                                        }];
    }
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    PUBDocument *document = self.publishedDocuments[indexPath.item];
    PUBCellView *cell = (PUBCellView *)[self.collectionView cellForItemAtIndexPath:indexPath];
    
    switch (document.state) {
        case PUBDocumentStateDownloaded:
            [self showDocument:document forCell:cell forIndex:indexPath.row];
            break;
            
        case PUBDocumentPurchased:
            [self showDocument:document forCell:cell forIndex:indexPath.row];
            break;
            
        default:
            self.transitioningDelegate.scaleTransition.transitionSourceView = cell;
            [self showPreviewForDocument:document];
            break;
    }
}

#pragma mark - Actions

- (void)deleteButtonClicked:(UIButton *)button  {
    if ([button isKindOfClass:UIButton.class]) {
        NSIndexPath *indexPath = [self.collectionView
                                  indexPathForItemAtPoint:[self.collectionView convertPoint:button.center fromView:button.superview]];
        PUBDocument *document = (self.publishedDocuments)[indexPath.row];
        [self removePdfForDocument:document];
    }
}

- (void)restorePurchases {
    [IAPController.sharedInstance restorePurchasesWithCompletion:^(NSError *error) {
        if (error == nil) {
            [IAPController.sharedInstance readReceiptDataWithCompletion:^(NSData *receipt) {
                [PUBCommunication.sharedInstance sendRestoreReceiptData:receipt
                                                             completion:^(id responseObject) {
                                                                 // save secrets in keychain
                                                                 if ([NSJSONSerialization isValidJSONObject:responseObject]) {
                                                                     NSDictionary *jsonData = (NSDictionary *)responseObject;
                                                                     NSArray *productIDs = jsonData.allKeys;
                                                                     
                                                                     for (NSString *productID in productIDs) {
                                                                         NSString *secret = PUBSafeCast(jsonData[productID], NSString.class);
                                                                         if (secret.length > 0) {
                                                                             [IAPController.sharedInstance setIAPSecret:secret productID:productID];
                                                                         }
                                                                     }
                                                                     
                                                                     // update state of documents
                                                                     for (PUBDocument *document in [PUBDocument findAll]) {
                                                                         if ([productIDs containsObject:document.productID]) {
                                                                             document.state = PUBDocumentPurchased;
                                                                         }
                                                                     }
                                                                     [PUBCoreDataStack.sharedCoreDataStack saveContext];
                                                                     [self performSelectorOnMainThread:@selector(displayRestoreSuccessMessage) withObject:nil waitUntilDone:NO];
                                                                 }
                                                             }
                                                                  error:^(NSError *sendError) {
                                                                      [self performSelectorOnMainThread:@selector(displayRestoreFailedMessage) withObject:nil waitUntilDone:NO];
                                                                  }];
            } error:^(NSError *receiptError) {
                PUBLogError(@"%@: Error reading receipt: %@", self.class, error.localizedDescription);
                // no receipt, do nothing
            }];
        }
        else {
            [self performSelectorOnMainThread:@selector(displayRestoreFailedMessage) withObject:nil waitUntilDone:NO];
        }
    }];
}

- (void)displayRestoreSuccessMessage {
    [[[UIAlertView alloc] initWithTitle:PUBLocalize(@"Purchases")
                                message:PUBLocalize(@"Your purchases have been restored.")
                               delegate:nil
                      cancelButtonTitle:PUBLocalize(@"OK")
                      otherButtonTitles:nil] show];
    [self.collectionView reloadData];
}

- (void)displayRestoreFailedMessage {
    [[[UIAlertView alloc] initWithTitle:PUBLocalize(@"Purchases")
                                message:PUBLocalize(@"Your purchases could not be restored. Please try again later.")
                               delegate:nil
                      cancelButtonTitle:PUBLocalize(@"OK")
                      otherButtonTitles:nil] show];
}

- (void)clearPurchases {
    [IAPController.sharedInstance clearPurchases];
}

- (void)handleLongPressgesture:(UILongPressGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {
        CGPoint point = [gesture locationInView:self.collectionView];
        NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:point];
        
        if (indexPath) {
            PUBCellView *cell = (PUBCellView *)[self.collectionView cellForItemAtIndexPath:indexPath];
            PUBDocument *document = self.publishedDocuments[indexPath.item];
            
            CGFloat endAlpha;
            CGAffineTransform endTransform;
            BOOL startAnimation = NO;
            
            if (cell.deleteButton.hidden && document.state == PUBDocumentStateDownloaded) {
                startAnimation = YES;
                cell.showDeleteButton = YES;
                endAlpha = 0.98f;
                cell.deleteButton.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
                endTransform = CGAffineTransformMakeScale(1.0f, 1.0f);
            } else {
                endAlpha = 0.0f;
                endTransform = CGAffineTransformMakeScale(0.1f, 0.1f);
            }
            
            [UIView animateWithDuration:0.25f
                                  delay:0
                 usingSpringWithDamping:10.f
                  initialSpringVelocity:10.f
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 cell.deleteButton.transform = endTransform;
                                 cell.deleteButton.alpha = endAlpha;
                             }
                             completion:^(BOOL finished) {
                                 if (finished) {
                                     cell.deleteButton.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
                                     
                                     if (!startAnimation) {
                                         cell.showDeleteButton = NO;
                                     }
                                 }
                             }];
            
        }
    }
}

#pragma mark - Helper

- (UIImage *)imageForDocument:(PUBDocument *)document {
    if (!document) return nil;
    
    NSUInteger lastPage = document.lastViewState.page;
    UIImage *coverImage = [PSPDFCache.sharedCache imageFromDocument:[PUBPDFDocument documentWithPUBDocument:document]
                                                               page:lastPage
                                                               size:UIScreen.mainScreen.bounds.size
                                                            options:PSPDFCacheOptionDiskLoadSkip|PSPDFCacheOptionRenderQueue|PSPDFCacheOptionMemoryStoreAlways];
    return coverImage;
}

- (void)removePdfForDocument:(PUBDocument *)document {
    [document deleteDocument:^{
        [NSNotificationCenter.defaultCenter postNotificationName:PUBStatisticsDocumentDeletedNotification
                                                          object:nil
                                                        userInfo:@{PUBStatisticsTimestampKey: [NSString stringWithFormat:@"%.0f",
                                                                                               NSDate.date.timeIntervalSince1970],
                                                                   PUBStatisticsDocumentIDKey: document.productID,
                                                                   PUBStatisticsEventKey : PUBStatisticsDeletedKey }];
        [self.collectionView reloadData];
    }];
}

// Calculates where the document view will be on screen.
- (CGRect)magazinePageCoordinatesWithDoublePageCurl:(BOOL)doublePageCurl onFirstPage:(BOOL)firstPage {
    CGRect newFrame = self.view.frame;

    // Animation needs to be different if we are in pageCurl mode.
    if (doublePageCurl) {
        newFrame.size.width /= 2;
        if (firstPage) {
            newFrame.origin.x += newFrame.size.width;
        } else {
            newFrame.origin.x = 0;
        }
    }
    return newFrame;
}

- (void)setupNavigationItems {
    self.navigationController.toolbar.tintColor = UIColor.publissPrimaryColor;
    self.navigationController.navigationBar.barTintColor = UIColor.publissPrimaryColor;
    self.navigationItem.title = PUBLocalize(@"Publiss");
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:UIApplication.sharedApplication.delegate.window.tintColor};
}

- (void)showAbout {
    [[[UIAlertView alloc] initWithTitle:PUBLocalize(@"Publiss")
                                message:[NSString stringWithFormat:PUBLocalize(@"About Publiss %@ \n %@"), PUBVersionString(), PSPDFKit.sharedInstance.version]
                               delegate:self
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil] show];
}

- (void)visitPublissSite {
    PSPDFWebViewController *webViewController = [[PSPDFWebViewController alloc] initWithURL:[NSURL URLWithString:PUBLocalize(@"Menu Website URL")]];
    [self.navigationController pushViewController:webViewController animated:YES];
}

#pragma mark - Notifications

- (void)enableUIInteraction:(NSNotification *)notification {
    if (!self.view.userInteractionEnabled) {
        self.collectionView.userInteractionEnabled = YES;
        self.view.userInteractionEnabled = YES;
    }
}

- (void)trackPage {
    [self.pageTracker fire];
}

- (void)documentFetcherDidUpdate:(NSNotification *)notification {
    if ([notification.userInfo isKindOfClass:NSDictionary.class]) {
        NSString *productID = [[notification.userInfo allKeys] firstObject];
        NSIndexPath *indexPath = [self indexPathForProductID:productID];
        PUBDocument *document = self.publishedDocuments[indexPath.item];
        
        if (document && document.state == PUBDocumentStateLoading) {
            NSDictionary *documentProgress = notification.userInfo[document.productID];
            document.downloadProgress = [documentProgress[@"totalProgress"] floatValue];
            
            PUBCellView *cell = (PUBCellView *)[self.collectionView cellForItemAtIndexPath:indexPath];
            [cell setupForDocument:document];
        }
    }
}

- (void)documentFetcherDidFinish:(NSNotification *)notification {
    if ([notification.userInfo isKindOfClass:NSDictionary.class]) {
        NSString *productID = [notification.userInfo objectForKey:PUBStatisticsDocumentIDKey];
        NSIndexPath *indexPath = [self indexPathForProductID:productID];
        PUBDocument *document = self.publishedDocuments[indexPath.item];
        
        if (document) {
            document.state = PUBDocumentStateDownloaded;
            [PUBCoreDataStack.sharedCoreDataStack saveContext];
            
            PUBCellView *cell = (PUBCellView *)[self.collectionView cellForItemAtIndexPath:indexPath];
            [cell setupForDocument:document];
        }
    }
}

- (void)documentPurchased:(NSNotification *)notification {
    if ([notification.userInfo isKindOfClass:NSDictionary.class]) {
        NSIndexPath *indexPath = [self indexPathForProductID:notification.userInfo[@"productID"]];
        PUBDocument *document = self.publishedDocuments[indexPath.item];
        
        if (document) {
            document.state = PUBDocumentPurchased;
            [PUBCoreDataStack.sharedCoreDataStack saveContext];
            
            PUBCellView *cell = (PUBCellView *)[self.collectionView cellForItemAtIndexPath:indexPath];
            [cell setupForDocument:document];
        }
    }
}

- (NSIndexPath *)indexPathForProductID:(NSString *)productID {
    if (!self.indexPathsForDocuments) {
        self.indexPathsForDocuments = [NSDictionary new];
    }
    
    NSIndexPath *indexPath = self.indexPathsForDocuments[productID];
    if (!indexPath) {
        for (NSInteger i = 0; i < self.publishedDocuments.count; i++) {
            PUBDocument *document = self.publishedDocuments[i];
            if ([document.productID isEqualToString:productID]) {
                indexPath = [NSIndexPath indexPathForItem:i inSection:0];
                
                NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:self.indexPathsForDocuments];
                [dictionary setObject:indexPath forKey:document.productID];
                self.indexPathsForDocuments = dictionary;
                break;
            }
        }
    }
    
    return indexPath;
}

- (void)setPublishedDocuments:(NSArray *)documentArray {
    _publishedDocuments = documentArray;
    self.indexPathsForDocuments = nil;
}

#pragma mark PSPDFViewControllerDelegate

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self trackPage];
}

- (void)pdfViewControllerWillDismiss:(PSPDFViewController *)pdfController {
    if (self.pageTracker.isValid) {
        [self trackPage];
    } else {
        [self.pageTracker invalidate];
    }
}

- (void)pdfViewController:(PSPDFViewController *)pdfController didLoadPageView:(PSPDFPageView *)pageView  {
    self.transitioningDelegate.scaleTransition.pageView = (PUBPageView *)pageView;
    [self trackPage];
}

- (void)pdfViewController:(PSPDFViewController *)pdfController didShowPageView:(PSPDFPageView *)pageView {
    if (self.pageTracker.isValid) {
        [self.pageTracker invalidate];
    }
    
    trackedPageTime = @(NSDate.date.timeIntervalSince1970);
    PUBDocument *document = PUBSafeCast(pdfController.document, PUBPDFDocument.class);
    NSDictionary *userInfo = @{PUBStatisticsEventTrackedPageKey: @(pageView.page),
                               PUBStatisticsDocumentIDKey: document.productID};
    
    self.pageTracker = [NSTimer scheduledTimerWithTimeInterval:100000 /* absurd high number so nothing gets tracked */
                                                        target:self
                                                      selector:@selector(updateUpdateTrackingInformationWithProductID:)
                                                      userInfo:userInfo
                                                       repeats:NO];

}

- (void)updateUpdateTrackingInformationWithProductID:(NSTimer *)timer {
    NSNumber *currentTime = @(NSDate.date.timeIntervalSince1970);
    trackedPageTime = @(currentTime.integerValue - trackedPageTime.integerValue);
    
    if (trackedPageTime.integerValue > [[PUBConfig sharedConfig] pageTrackTime].integerValue) {
        NSMutableArray *pageTracking = [[NSMutableArray alloc] init];
        if (UIInterfaceOrientationIsLandscape(UIApplication.sharedApplication.statusBarOrientation)) {
            [pageTracking addObject:@{PUBStatisticsTimestampKey : [NSString stringWithFormat:@"%.0f", NSDate.date.timeIntervalSince1970],
                                      PUBStatisticsEventTrackedPageKey : timer.userInfo[PUBStatisticsEventTrackedPageKey],
                                      PUBStatisticsEventKey: PUBStatisticsEventReadKey,
                                      PUBStatisticsDocumentIDKey : timer.userInfo[PUBStatisticsDocumentIDKey],
                                      PUBStatisticsPageDurationKey : trackedPageTime}];
            [pageTracking addObject:@{PUBStatisticsTimestampKey : [NSString stringWithFormat:@"%.0f", NSDate.date.timeIntervalSince1970],
                                      PUBStatisticsEventTrackedPageKey : @([timer.userInfo[PUBStatisticsEventTrackedPageKey] integerValue] + 1),
                                      PUBStatisticsEventKey: PUBStatisticsEventReadKey,
                                      PUBStatisticsDocumentIDKey : timer.userInfo[PUBStatisticsDocumentIDKey],
                                      PUBStatisticsPageDurationKey : trackedPageTime}];
        } else {
            [pageTracking addObject:@{PUBStatisticsTimestampKey : [NSString stringWithFormat:@"%.0f", NSDate.date.timeIntervalSince1970],
                                      PUBStatisticsEventTrackedPageKey : timer.userInfo[PUBStatisticsEventTrackedPageKey],
                                      PUBStatisticsEventKey: PUBStatisticsEventReadKey,
                                      PUBStatisticsDocumentIDKey : timer.userInfo[PUBStatisticsDocumentIDKey],
                                      PUBStatisticsPageDurationKey : trackedPageTime}];

        }
        for (NSDictionary *pageTrack in pageTracking) {
            [NSNotificationCenter.defaultCenter postNotificationName:PUBDocumentPageTrackedNotification
                                                              object:nil
                                                            userInfo:pageTrack];
        }
    }
}

#pragma mark - Show Preview/Document

- (void)showPreviewForDocument:(PUBDocument *)document {
    PUBPreviewViewController *previewViewController = [PUBPreviewViewController instantiatePreviewController];
    previewViewController.document = document;
    previewViewController.kioskController = self;
    
    NSIndexPath *indexPath = [self indexPathForProductID:document.productID];
    if (indexPath) {
        PUBCellView *cell =  (PUBCellView*)[self.collectionView cellForItemAtIndexPath:indexPath];
        
        self.transitioningDelegate.selectedTransition = PUBSelectedTransitionScale;
        self.transitioningDelegate.scaleTransition.modal = YES;
        self.transitioningDelegate.scaleTransition.dimView = self.dimView;
        self.transitioningDelegate.scaleTransition.transitionSourceView = cell;
        
        previewViewController.cell = cell;
        previewViewController.selectedIndex = indexPath.row;
    }
    else {
        self.transitioningDelegate.selectedTransition = PUBSelectedTransitionCrossfade;
    }
    
    UIViewController *controllerToPresent = previewViewController;
    if (!PUBIsiPad()) {
        controllerToPresent = [[UINavigationController alloc] initWithRootViewController:previewViewController];
    }
    
    controllerToPresent.modalPresentationStyle = UIModalPresentationCustom;
    controllerToPresent.transitioningDelegate = self.transitioningDelegate;
    
    self.view.userInteractionEnabled = NO;
    self.collectionView.userInteractionEnabled = NO;
    [self presentViewController:controllerToPresent animated:YES completion:nil];
}

- (void)showDocument:(PUBDocument *)document forCell:(PUBCellView *)cell forIndex:(NSUInteger)index {
    NSURL *URL = document.localDocumentURL;
    if (!URL) {
        PUBLogError(@"Failed loading local document: %@", URL.absoluteString);
    } else {
        if (self.isOpening) {
            return;
        }
        self.view.userInteractionEnabled = NO;
        self.collectionView.userInteractionEnabled = NO;
        self.isOpening = YES;
        self.lastOpenedDocument = document;
        PUBPDFDocument *pdfDocument = [PUBPDFDocument documentWithPUBDocument:document];
        [PUBPDFDocument restoreLocalAnnotations:pdfDocument];
        PUBPDFViewController *pdfController = [[PUBPDFViewController alloc] initWithDocument:pdfDocument];
        pdfController.delegate = self;
        pdfController.kioskViewController = self;
        
        UIImage *coverImage = [self imageForDocument:document];
        if (nil == coverImage) {
            coverImage = cell.coverImage.image;
        }
        CGRect cellCoords = [cell.coverImage convertRect:cell.coverImage.bounds toView:self.view];
        UIImageView *coverImageView = [[UIImageView alloc] initWithImage:coverImage];
        coverImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        coverImageView.frame = cellCoords;
        coverImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.view addSubview:coverImageView];
        self.documentView = coverImageView;
        _animationCellIndex = index;
        
        if (!PUBIsiPad()) {
            [UIApplication.sharedApplication setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
        }
        
        // If we have a different page, fade to that page.
        UIImageView *targetPageImageView = nil;
        if (pdfController.page != 0 && !pdfController.isDoublePageMode) {
            UIImage *targetPageImage = [PSPDFCache.sharedCache imageFromDocument:pdfDocument page:pdfController.page size:UIScreen.mainScreen.bounds.size options:PSPDFCacheOptionDiskLoadSkip|PSPDFCacheOptionRenderSkip|PSPDFCacheOptionMemoryStoreAlways];
            if (targetPageImage) {
                targetPageImageView = [[UIImageView alloc] initWithImage:targetPageImage];
                targetPageImageView.frame = self.documentView.bounds;
                targetPageImageView.contentMode = UIViewContentModeScaleAspectFit;
                targetPageImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
                targetPageImageView.alpha = 0.f;
                [self.documentView addSubview:targetPageImageView];
            }
        }
        cell.hidden = YES;
        self.dimView.hidden = NO;
        [UIView animateWithDuration:0.3f delay:0.f options:0 animations:^{
            self.navigationController.navigationBar.alpha = 0.f;
            self.dimView.alpha = 1.0f;
            _animationDoubleWithPageCurl = pdfController.configuration.pageTransition == PSPDFPageTransitionCurl && pdfController.isDoublePageMode;
            CGRect newFrame = [self magazinePageCoordinatesWithDoublePageCurl:_animationDoubleWithPageCurl onFirstPage:(self.lastOpenedDocument.lastViewState.page == 0)];
            coverImageView.frame = newFrame;
            targetPageImageView.alpha = 1.f;
        } completion:^(BOOL finished) {
            CATransition *transition = [CATransition animation];
            transition.duration = 0.25f;
            transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            transition.type = kCATransitionFade;
            [self.navigationController.navigationBar.layer addAnimation:transition forKey:kCATransition];
            self.isOpening = NO;
            self.view.userInteractionEnabled = YES;
            self.collectionView.userInteractionEnabled = YES;
            [self.navigationController pushViewController:pdfController animated:NO];
            [NSNotificationCenter.defaultCenter postNotificationName:PUBDocumentDidOpenNotification
                                                              object:nil userInfo:@{PUBStatisticsTimestampKey: [NSString stringWithFormat:@"%.0f", NSDate.date.timeIntervalSince1970],
                                                                                    PUBStatisticsDocumentIDKey: document.productID,
                                                                                    PUBStatisticsEventKey: PUBStatisticsEventOpenKey }];
        }];
    }
}

@end
