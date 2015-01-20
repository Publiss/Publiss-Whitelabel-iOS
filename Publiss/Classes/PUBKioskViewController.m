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
#import "UIImageView+AFNetworking.h"
#import "PUBPDFDocument.h"
#import "IAPController.h"
#import "PUBHTTPRequestManager.h"
#import "JDStatusBarNotification.h"
#import "UIImage+PUBTinting.h"
#import "PSPDFWebViewController.h"
#import "PUBCoreDataStack.h"
#import "PUBConstants.h"
#import <PublissCore.h>
#import "PUBKioskLayout.h"
#import "PUBHeaderReusableView+Documents.h"
#import "PUBFooterReusableView.h"
#import "UIActionSheet+Blocks.h"

#import "PUBTransitioningDelegate.h"
#import "PUBFadeTransition.h"
#import "PUBDocumentTransition.h"
#import "REFrostedViewController.h"
#import "PUBMenuItem.h"
#import "PUBMenuItemManager.h"
#import "PUBUserLoginViewController.h"
#import "UIImage+ImageEffects.h"
#import <KVNProgress/KVNProgress.h>
#import "PUBAuthentication.h"
#import "PUBMenuItemAccount.h"
#import "PUBLanguage+Helper.h"

@interface PUBKioskViewController () <PSPDFViewControllerDelegate, PUBDocumentTransitionDataSource, PUBUserLoginDelegate>

@property (nonatomic, strong) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) PUBKioskLayout *kioskLayout;
@property (nonatomic, weak) PUBHeaderReusableView *headerView;

@property (nonatomic, strong) PUBTransitioningDelegate *transitioningDelegate;
@property (nonatomic, strong) PUBDocument *presentedDocument;
@property (nonatomic, assign) BOOL isPresentingController;

@property (nonatomic, copy) NSArray *featuredDocuments;
@property (nonatomic, copy) NSArray *publishedDocuments;

@property (nonatomic, strong) NSMutableSet *dynamicallyLoadedCoverImageIndexPath;
@property (nonatomic, strong) NSDictionary *indexPathsForDocuments;
@property (nonatomic, strong) NSDictionary *indexPathsForDocumentsByLinkedTag;
@property (nonatomic, strong) NSTimer *pageTracker;

@property (nonatomic, strong) UIRefreshControl *refreshControl;

@end

#define LINE_HEIGHT 30.f

@implementation PUBKioskViewController {
    NSNumber *trackedPageTime;
}

+ (PUBKioskViewController *)kioskViewController {
    return [PUBKioskViewController kioskViewControllerWithStoryboardName:@"PUBKiosk"];
}

+ (PUBKioskViewController *)kioskViewControllerWithStoryboardName:(NSString *)storyboard {
    return [[UIStoryboard storyboardWithName:storyboard bundle:nil] instantiateInitialViewController];
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:1.0f];
    
    self.dynamicallyLoadedCoverImageIndexPath = [NSMutableSet set];
    
    [self setupNavigationItems];
    [self setupCollectionView];
    [self setupMenu];
    
    [JDStatusBarNotification addStyleNamed:PurchasedMenuStyle
                                   prepare:^JDStatusBarStyle *(JDStatusBarStyle *style) {
                                       style.barColor = [UIColor whiteColor];
                                       style.textColor = [UIColor publissPrimaryColor];
                                       style.animationType = JDStatusBarAnimationTypeBounce;
                                       style.font = [UIFont boldSystemFontOfSize:13.f];
                                       return style;
                                   }];
    
    self.transitioningDelegate = [PUBTransitioningDelegate new];
    
    [self refreshDocumentsWithActivityViewAnimated:YES];
    [self.view addGestureRecognizer:[UIPanGestureRecognizer.alloc initWithTarget:self action:@selector(panGestureRecognized:)]];
    
    [self setupRefreshControl];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSNotificationCenter *dnc = NSNotificationCenter.defaultCenter;
    [dnc addObserver:self selector:@selector(trackPage) name:UIApplicationWillResignActiveNotification object:nil];
    [dnc addObserver:self selector:@selector(refreshDocumentsWithActivityViewAnimated:) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    [dnc addObserver:self selector:@selector(documentFetcherDidUpdate:) name:PUBDocumentFetcherUpdateNotification object:NULL];
    [dnc addObserver:self selector:@selector(documentFetcherDidFinish:) name:PUBDocumentDownloadNotification object:NULL];
    [dnc addObserver:self selector:@selector(documentPurchased:) name:PUBDocumentPurchaseFinishedNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.shouldRetrieveDocuments) {
        self.shouldRetrieveDocuments = NO;
        [self refreshDocumentsWithActivityViewAnimated:YES];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    NSNotificationCenter *dnc = NSNotificationCenter.defaultCenter;
    [dnc removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [dnc removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    
    [dnc removeObserver:self name:PUBDocumentFetcherUpdateNotification object:nil];
    [dnc removeObserver:self name:PUBDocumentDownloadNotification object:nil];
    [dnc removeObserver:self name:PUBDocumentPurchaseFinishedNotification object:nil];
    
    if (self.pageTracker.isValid) {
        [self.pageTracker invalidate];
        self.pageTracker = nil;
    }
}

#pragma mark - Setup

- (void)setupNavigationItems {
    self.navigationController.toolbar.tintColor = UIColor.publissPrimaryColor;
    self.navigationController.navigationBar.tintColor = UIColor.publissSecondaryColor;
    self.navigationController.navigationBar.barStyle = UIStatusBarStyleLightContent;
    self.navigationController.navigationBar.barTintColor = UIColor.publissPrimaryColor;
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:UIColor.publissSecondaryColor};
    
    self.navigationItem.title = PUBLocalize(@"Publiss");
}

- (void)setupCollectionView {
    self.collectionView.backgroundColor = [[UIColor colorWithPatternImage:[UIImage imageNamed:@"KioskShelveBackground"]] colorWithAlphaComponent:1.0f];
    self.kioskLayout = [[PUBKioskLayout alloc] init];
    self.collectionView.collectionViewLayout = self.kioskLayout;
    [self.collectionView.collectionViewLayout invalidateLayout];
    [self.collectionView registerClass:[PUBHeaderReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"PUBHeaderReusableView"];
    [self.collectionView registerClass:[PUBFooterReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"PUBFooterReusableView"];
    
    UILongPressGestureRecognizer *longpressGesture = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(handleLongPressgesture:)];
    [self.collectionView addGestureRecognizer:longpressGesture];
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
}

- (void)setupRefreshControl {
    if (!self.refreshControl) {
        self.refreshControl = UIRefreshControl.alloc.init;
        self.refreshControl.tintColor = [UIColor publissPrimaryColor];
        [self.refreshControl addTarget:self action:@selector(refreshDocumentsWithActivityViewAnimated:) forControlEvents:UIControlEventValueChanged];
        [self.collectionView addSubview:self.refreshControl];
    }
}

- (void)setupMenu {
    UIBarButtonItem *menuItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu_icon"]
                                                                 style:UIBarButtonItemStylePlain
                                                                target:self
                                                                action:@selector(showMenu:)];
    self.navigationItem.leftBarButtonItems = @[menuItem];
    
    PUBMenuItem *visit = PUBMenuItem.alloc.init;
    visit.title = PUBLocalize(@"Visit Publiss Website");
    visit.icon = [[UIImage imageNamed:@"web"] imageTintedWithColor:[UIColor publissSecondaryColor] fraction:0.f];
    visit.actionBlock = ^() {
        [self visitPublissSite];
    };
    [PUBMenuItemManager.sharedInstance addMenuItem:visit];
    
    PUBMenuItem *about = PUBMenuItem.alloc.init;
    about.title = PUBLocalize(@"About Publiss");
    about.icon = [[UIImage imageNamed:@"about"] imageTintedWithColor:[UIColor publissSecondaryColor] fraction:0.f];
    about.actionBlock = ^() {
        [self showAbout];
    };
    [PUBMenuItemManager.sharedInstance addMenuItem:about];
    
    if (PUBAuthentication.sharedInstance.loginEnabled) {
        PUBMenuItemAccount *userLogin = PUBMenuItemAccount.alloc.init;
        userLogin.actionBlockLogin = ^() {
            if ([self isAnyDocumentCurrentlyLoading]) {
                [KVNProgress setConfiguration:[self notifyMessageConfiguration]];
                [KVNProgress showErrorWithStatus:PUBLocalize(@"Please wait until download is completed.")];
            }
            else {
                [self showUserLogin];
            }
        };
        userLogin.actionBlockLogout = ^() {
            if ([self isAnyDocumentCurrentlyLoading]) {
                [KVNProgress setConfiguration:[self notifyMessageConfiguration]];
                [KVNProgress showErrorWithStatus:PUBLocalize(@"Please wait until download is completed.")];
            }
            else {
                [PUBAuthentication.sharedInstance logout];
                for (PUBDocument *document in self.publishedDocuments) {
                    [self removePdfForDocument:document];
                }
                [self refreshDocumentsWithActivityViewAnimated:YES];
                
                [KVNProgress setConfiguration:[self notifyMessageConfiguration]];
                [KVNProgress showWithStatus:PUBLocalize(@"Logging out ...")];
            }
        };
        [PUBMenuItemManager.sharedInstance addMenuItem:userLogin];
    }
    
    if (PUBConfig.sharedConfig.inAppPurchaseActive) {
        PUBMenuItem *restore = PUBMenuItem.alloc.init;
        restore.title = PUBLocalize(@"Restore Purchases");
        restore.icon = [[UIImage imageNamed:@"restore"] imageTintedWithColor:[UIColor publissSecondaryColor] fraction:0.f];
        restore.actionBlock = ^() {
            [self restorePurchases];
        };
        [PUBMenuItemManager.sharedInstance addMenuItem:restore];
        
#ifdef DEBUG
        PUBMenuItem *clear = PUBMenuItem.alloc.init;
        clear.title = @"(DEBUG) Clear";
        clear.actionBlock = ^() {
            [self clearPurchases];
        };
        [PUBMenuItemManager.sharedInstance addMenuItem:clear];
#endif
    }
}

#pragma mark - Gesture

- (void)panGestureRecognized:(UIPanGestureRecognizer *)sender {
    [self.view endEditing:YES];
    [self.frostedViewController.view endEditing:YES];
    [self.frostedViewController panGestureRecognized:sender];
}

#pragma mark - Actions

- (void)refreshDocumentsWithActivityViewAnimated:(BOOL)animated {    
    self.editButtonItem.enabled = NO;
    
    if (!self.refreshControl.isRefreshing) {
        [self.refreshControl beginRefreshing];
    }
    
    self.dynamicallyLoadedCoverImageIndexPath = [NSMutableSet set];
    [PUBCommunication.sharedInstance fetchAndSaveDocuments:^{
        [PUBCoreDataStack.sharedCoreDataStack saveContext];
        
        if (PUBConfig.sharedConfig.preferredLanguage.length > 0) {
            
            NSArray *localizedDocuments = [PUBDocument fetchAllWithPreferredLanguage:PUBConfig.sharedConfig.preferredLanguage
                                                           fallbackLanguage:PUBConfig.sharedConfig.fallbackLanguage
                                            showingLocalizationIfNoFallback:PUBConfig.sharedConfig.showAnyLocalizationIfThereIsNoFallback
                                                   showUnlocalizedDocuments:PUBConfig.sharedConfig.showUnlocalizedDocuments];
            
            self.publishedDocuments = [PUBDocument sortDocuments:localizedDocuments
                                                        sortedBy:SortOrder
                                                       ascending:YES
                                                       predicate:[NSPredicate predicateWithFormat:@"showInKiosk == YES"]];
            
            self.featuredDocuments = [PUBDocument sortDocuments:localizedDocuments
                                                       sortedBy:SortOrder
                                                      ascending:YES
                                                      predicate:[NSPredicate predicateWithFormat:@"featured == YES"]];
        }
        else {
            self.publishedDocuments = [PUBDocument fetchAllSortedBy:SortOrder
                                                          ascending:YES
                                                          predicate:[NSPredicate predicateWithFormat:@"showInKiosk == YES"]];
            self.featuredDocuments = [PUBDocument fetchAllSortedBy:SortOrder
                                                         ascending:YES
                                                         predicate:[NSPredicate predicateWithFormat:@"featured == YES"]];
        }
        
        
        
        self.kioskLayout.showsHeader = self.featuredDocuments.count > 0;
        if (self.publishedDocuments.count > 0) {
            self.collectionView.backgroundColor = [UIColor kioskBackgroundColor];
        } else {
            self.collectionView.backgroundColor = [[UIColor colorWithPatternImage:[UIImage imageNamed:@"KioskShelveBackground"]] colorWithAlphaComponent:1.0f];
        }
        
        [self.collectionView reloadData];
        
        self.editButtonItem.enabled = YES;
        [self.refreshControl endRefreshing];
        
        [KVNProgress dismissWithCompletion:^{}];
    }
                                                     error:^(NSError *error) {
                                                         PUBAuthentication *auth = PUBAuthentication.sharedInstance;
                                                         if ([auth isLoggedIn]) {
                                                             [auth logout];
                                                             [self refreshDocumentsWithActivityViewAnimated:YES];
                                                             
                                                             [KVNProgress setConfiguration:[self notifyMessageConfiguration]];
                                                             [KVNProgress showErrorWithStatus:PUBLocalize(@"You have been logged out!\nPlease login again.")];
                                                         }
                                                     }];
}

- (void)showMenu:(id)sender {
    [self.frostedViewController presentMenuViewController];
}

- (void)showAbout {
    [[[UIAlertView alloc] initWithTitle:PUBLocalize(@"Publiss")
                                message:[NSString stringWithFormat:PUBLocalize(@"About Publiss %@ \n %@"), PUBVersionString(), PSPDFKit.sharedInstance.version]
                               delegate:nil
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil] show];
}

- (void)showUserLogin {
    PUBUserLoginViewController *userViewController = [PUBUserLoginViewController userLoginViewControllerWithDelegate:self];
    
    userViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    userViewController.modalPresentationStyle = UIModalPresentationFormSheet;
    
    [self.navigationController presentViewController:userViewController animated:YES completion:^{}];
}

- (void)visitPublissSite {
    if (self.navigationController.topViewController == self) {
        PSPDFWebViewController *webViewController = [[PSPDFWebViewController alloc] initWithURL:[NSURL URLWithString:PUBLocalize(@"Menu Website URL")]];
        self.navigationController.delegate = nil;
        [self.navigationController pushViewController:webViewController animated:YES];
    }
}

#pragma mark - PUBUserLoginDelegate

- (BOOL)pubUserLoginWillLoginWithCredentials:(NSDictionary *)credentials
{
    [KVNProgress setConfiguration:[self fullScreenBlockingProgressConfiguration]];
    [KVNProgress showWithStatus:PUBLocalize(@"Authenticating ...")];
    return YES;
}

- (void)pubUserLoginFailedWithError:(NSString *)message
{
    [KVNProgress showErrorWithStatus:PUBLocalize(message)];
}

- (void)pubUserLoginSucceededWithToken:(NSString *)token andResponse:(NSDictionary *)response andParameters:(NSDictionary *)parameters
{
    [PUBAuthentication.sharedInstance setLoggedInWithToken:token andMetadata:response];
    [KVNProgress showWithStatus:PUBLocalize(@"You are logged in!\n\nPreparing kiosk for your personal experience ...")];
    
    [self.navigationController dismissViewControllerAnimated:NO completion:nil];
    [self refreshDocumentsWithActivityViewAnimated:YES];
}

#pragma mark - UICollectionView DataSoure

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.publishedDocuments.count;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if (kind == UICollectionElementKindSectionHeader) {
        PUBHeaderReusableView *header = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                                           withReuseIdentifier:@"PUBHeaderReusableView"
                                                                                  forIndexPath:indexPath];
        [header setupWithDocuments:self.featuredDocuments];
        
        header.singleTapBlock = ^() {
            [self presentDocumentAccordingToState:self.featuredDocuments.firstObject atIndexPath:nil];
        };
        
        __weak typeof(header) weakHeader = header;
        header.longPressBlock = ^() {
            
            PUBDocument *document = self.featuredDocuments.firstObject;
            
            if (document.state == PUBDocumentStateDownloaded) {
                [UIActionSheet showInView:weakHeader
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
        
        self.headerView = header;
        return header;
    } else {
        PUBFooterReusableView *footer = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                                           withReuseIdentifier:@"PUBFooterReusableView"
                                                                                  forIndexPath:indexPath];
        [collectionView sendSubviewToBack:footer];
        return footer;
    }
}

- (void)prepareCellWithThumbnail:(UIImage *)thumbnail cell:(PUBCellView *)cell indexPath:(NSIndexPath *)indexPath document:(PUBDocument *)document
{
    cell.coverImage.image = thumbnail;
    cell.coverImage.hidden = NO;
    [cell.activityIndicator stopAnimating];
    if ([self.dynamicallyLoadedCoverImageIndexPath containsObject:indexPath]) {
        cell.transform = CGAffineTransformMakeScale(.1f, .1f);
        [UIView animateWithDuration:.4f animations:^{
            cell.transform = CGAffineTransformIdentity;
        } completion:NULL];
        [self.dynamicallyLoadedCoverImageIndexPath removeObject:indexPath];
    }
}

- (void)prepareCellWithoutThumbnail:(PUBCellView *)cell indexPath:(NSIndexPath *)indexPath collectionView:(UICollectionView *)collectionView thumbnailURL:(NSURL *)thumbnailURL
{
    [cell.activityIndicator startAnimating];
    cell.coverImage.hidden = YES;
    cell.namedBadgeView.hidden = YES;
    [cell setBadgeViewHidden:YES animated:NO];
    if (![self.dynamicallyLoadedCoverImageIndexPath containsObject:indexPath]) {
        NSURLRequest *URLRequest = [NSURLRequest requestWithURL:thumbnailURL];
        [self.dynamicallyLoadedCoverImageIndexPath addObject:indexPath];
        [cell.coverImage setImageWithURLRequest:URLRequest
                               placeholderImage:nil
                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                            
                                            [PUBThumbnailImageCache.sharedInstance setImage:image forURLString:thumbnailURL.absoluteString];
                                            // has to called later becuase the cache needs some time to write
                                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                                [collectionView reloadItemsAtIndexPaths:@[indexPath]];
                                            });
                                        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                                [collectionView reloadItemsAtIndexPaths:@[indexPath]];
                                            });
                                        }];
    }
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

    if (nil != thumbnail) {
        [self prepareCellWithThumbnail:thumbnail cell:cell indexPath:indexPath document:document];
    } else {
        [self prepareCellWithoutThumbnail:cell indexPath:indexPath collectionView:collectionView thumbnailURL:thumbnailURL];
    }
    [cell setNeedsLayout];
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    PUBDocument *document = self.publishedDocuments[indexPath.item];
    [self presentDocumentAccordingToState:document atIndexPath:indexPath];
}

#pragma mark - Actions

- (void)deleteButtonClicked:(UIButton *)button  {
    if ([button isKindOfClass:UIButton.class]) {
        NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:[self.collectionView convertPoint:button.superview.center fromView:button.superview]];
        PUBDocument *document = (self.publishedDocuments)[indexPath.row];
        
        if (document.language.linkedTag.length > 0) {
            NSArray *documents = [PUBDocument fetchAllSortedBy:@"language.localizedTitle"
                                                     ascending:YES
                                                     predicate:[NSPredicate predicateWithFormat:@"state == %lu AND language.linkedTag == %@", PUBDocumentStateDownloaded, document.language.linkedTag]];
            
            for (PUBDocument *documentToDelete in documents) {
                    [self removePdfForDocument:documentToDelete];
            }
        }
        else {
            [self removePdfForDocument:document];
        }
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

- (BOOL)isAnyDocumentCurrentlyLoading {
    BOOL isLoadingInProgress = NO;
    
    for (PUBDocument *document in self.publishedDocuments) {
        if (document.state == PUBDocumentStateLoading) {
            isLoadingInProgress = YES;
        }
    }
    
    return isLoadingInProgress;
}

#pragma mark - Notifications

- (void)trackPage {
    [self.pageTracker fire];
}

- (void)documentFetcherDidUpdate:(NSNotification *)notification {
    if ([notification.userInfo isKindOfClass:NSDictionary.class]) {
        NSString *productID = [[notification.userInfo allKeys] firstObject];
        NSIndexPath *indexPath = [self indexPathForProductID:productID];
        if (indexPath) {
            PUBDocument *document = self.publishedDocuments[indexPath.item];
            if (document && document.state == PUBDocumentStateLoading) {
                NSDictionary *documentProgress = notification.userInfo[document.productID];
                document.downloadProgress = [documentProgress[@"totalProgress"] floatValue];
                
                PUBCellView *cell = (PUBCellView *)[self.collectionView cellForItemAtIndexPath:indexPath];
                [cell setupForDocument:document];
            }
        }
    }
}

- (void)documentFetcherDidFinish:(NSNotification *)notification {
    if ([notification.userInfo isKindOfClass:NSDictionary.class]) {
        NSString *productID = [notification.userInfo objectForKey:PUBStatisticsDocumentIDKey];
        NSIndexPath *indexPath = [self indexPathForProductID:productID];
        if (indexPath) {
            PUBDocument *document = self.publishedDocuments[indexPath.item];
            
            if (!indexPath) {
                PUBDocument *featured = self.featuredDocuments.firstObject;
                if (featured && [featured.productID isEqual:productID]) {
                    document = featured;
                    document.state = PUBDocumentStateDownloaded;
                    [PUBCoreDataStack.sharedCoreDataStack saveContext];
                    
                    [self.headerView setupWithDocuments:@[document]];
                    [self.collectionView.collectionViewLayout invalidateLayout];
                }
            }
            else {
                if (document) {
                    document.state = PUBDocumentStateDownloaded;
                    [PUBCoreDataStack.sharedCoreDataStack saveContext];
                    
                    PUBCellView *cell = (PUBCellView *)[self.collectionView cellForItemAtIndexPath:indexPath];
                    [cell setupForDocument:document];
                }
            }
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

- (NSIndexPath *)indexPathForLinkedTag:(NSString *)linkedTag {
    if (!self.indexPathsForDocumentsByLinkedTag) {
        self.indexPathsForDocumentsByLinkedTag = [NSDictionary new];
    }
    
    NSIndexPath *indexPath = self.indexPathsForDocumentsByLinkedTag[linkedTag];
    if (!indexPath) {
        for (NSInteger i = 0; i < self.publishedDocuments.count; i++) {
            PUBDocument *document = self.publishedDocuments[i];
            NSLog(@"%ld: %@ ... %@", (long)i, document.language.linkedTag, linkedTag);
            
            if (document.language.linkedTag.length > 0 && [document.language.linkedTag isEqualToString:linkedTag]) {
                indexPath = [NSIndexPath indexPathForItem:i inSection:0];
                
                NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:self.indexPathsForDocumentsByLinkedTag];
                [dictionary setObject:indexPath forKey:document.language.linkedTag];
                self.indexPathsForDocumentsByLinkedTag = dictionary;
                break;
            }
        }
    }
    
    return indexPath;
}

- (void)setPublishedDocuments:(NSArray *)documentArray {
    _publishedDocuments = documentArray;
    self.indexPathsForDocuments = nil;
    self.indexPathsForDocumentsByLinkedTag = nil;
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
    [self trackPage];
}

- (void)pdfViewController:(PSPDFViewController *)pdfController didShowPageView:(PSPDFPageView *)pageView {
    self.transitioningDelegate.documentTransition.transitionImage = pageView.contentView.image;
    
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

#pragma mark - Publiss Statistics

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

- (void)dispatchStatisticsDocumentDidOpen:(PUBDocument *)document {
    [NSNotificationCenter.defaultCenter postNotificationName:PUBDocumentDidOpenNotification
                                                      object:nil userInfo:@{PUBStatisticsTimestampKey: [NSString stringWithFormat:@"%.0f", NSDate.date.timeIntervalSince1970],
                                                                            PUBStatisticsDocumentIDKey: document.productID,
                                                                            PUBStatisticsEventKey: PUBStatisticsEventOpenKey }];
}

#pragma mark - Present Preview/Document

- (NSUInteger)numberOfAvailableLanguagesForDocument:(PUBDocument *)document {
    return [PUBDocument fetchAllSortedBy:@"language.localizedTitle"
                               ascending:YES
                               predicate:[NSPredicate predicateWithFormat:@"language.linkedTag == %@", document.language.linkedTag]].count;
}

- (void)presentDocumentAccordingToState:(PUBDocument *)document atIndexPath:(NSIndexPath *)indexPath {
    if ([self numberOfAvailableLanguagesForDocument:document] == 1 && (document.state == PUBDocumentStateDownloaded || document.state == PUBDocumentPurchased)) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self presentDocument:document atIndexPath:indexPath];
        });
    }
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self presentPreviewForDocument:document atIndexPath:indexPath];
        });
    }
}

- (void)presentPreviewForDocument:(PUBDocument *)document atIndexPath:(NSIndexPath *)indexPath{
    
    if (self.isPresentingController) {
        return;
    }
    self.isPresentingController = YES;
    
    PUBPreviewViewController *previewViewController = [PUBPreviewViewController instantiatePreviewController];
    
    ((PUBPreviewViewController *)[((UINavigationController *)previewViewController).viewControllers firstObject]).document = document;
    ((PUBPreviewViewController *)[((UINavigationController *)previewViewController).viewControllers firstObject]).kioskController = self;
    
    if (indexPath) {
        PUBCellView *cell =  (PUBCellView*)[self.collectionView cellForItemAtIndexPath:indexPath];
        self.transitioningDelegate.selectedTransition = PUBSelectedTransitionScale;
        self.transitioningDelegate.scaleTransition.transitionSourceView = cell.coverImage;
        self.transitioningDelegate.scaleTransition.sourceImage = cell.coverImage.image;
        
        __weak typeof(self) welf = self;
        self.transitioningDelegate.scaleTransition.animationEndedBlock = ^(BOOL success, TransitionMode mode) {
            if (mode == TransitionModeDismiss) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [welf.collectionView reloadData];
                });
            }
        };
    }
    else {
        self.transitioningDelegate.selectedTransition = PUBSelectedTransitionFade;
        self.transitioningDelegate.fadeTransition.shouldHideStatusBar = NO;
        
        __weak typeof(self) welf = self;
        self.transitioningDelegate.fadeTransition.animationEndedBlock = ^(BOOL success, TransitionMode mode) {
            if (mode == TransitionModeDismiss) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [welf.collectionView reloadData];
                });
            }
        };
    }
    
    previewViewController.modalPresentationStyle = UIModalPresentationCustom;
    previewViewController.transitioningDelegate = self.transitioningDelegate;

    if (PUBIsiPad()) {
        ((UINavigationController *)previewViewController).view.layer.cornerRadius = 6;
        ((UINavigationController *)previewViewController).view.layer.masksToBounds = YES;
        previewViewController.view.frame = CGRectMake(0, 0, 540, 620);
        previewViewController.view.autoresizingMask = UIViewAutoresizingNone;
    }
    
    [self presentViewController:previewViewController animated:YES completion:^{
        // dirty stuff ... but otherwise double opening will happen
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.isPresentingController = NO;
        });
    }];
}

- (void)presentDocument:(PUBDocument *)document {
    NSIndexPath *indexPath = [self indexPathForProductID:document.productID];
    [self presentDocument:document atIndexPath:indexPath];
}

- (void)presentDocument:(PUBDocument *)document atIndexPath:(NSIndexPath *)indexPath {
    
    if (self.isPresentingController) {
        return;
    }
    self.isPresentingController = YES;
    
    self.presentedDocument = document;
    
    PUBPDFDocument *pdfDocument = [PUBPDFDocument documentWithPUBDocument:document];
    [PUBPDFDocument restoreLocalAnnotations:pdfDocument];
    PUBPDFViewController *pdfController = [[PUBPDFViewController alloc] initWithDocument:pdfDocument configuration:PSPDFConfiguration.defaultConfiguration];
    pdfController.delegate = self;
    pdfController.kioskViewController = self;
    
    UIViewController *controllerToPresent = pdfController;
    
    if (indexPath) {
        PUBCellView *cell = (PUBCellView*)[self.collectionView cellForItemAtIndexPath:indexPath];
        
        self.transitioningDelegate.selectedTransition = PUBSelectedTransitionDocument;
        self.transitioningDelegate.documentTransition.transitionSourceView = cell.coverImage;
        self.transitioningDelegate.documentTransition.transitionImage = cell.coverImage.image;
        self.transitioningDelegate.documentTransition.targetPosition = [PUBDocumentTransition targetPositionForPageIndex:pdfController.page
                                                                                                      isDoubleModeActive:pdfController.isDoublePageMode];
        self.transitioningDelegate.documentTransition.dataSource = self;
        
        if (pdfController.page != 0) {
            UIImage *targetPageImage = [self targetImageForDocument:pdfDocument page:pdfController.page];
            if (targetPageImage) {
                self.transitioningDelegate.documentTransition.transitionImage = targetPageImage;
            }
        }
    }
    else {
        self.transitioningDelegate.selectedTransition = PUBSelectedTransitionFade;
        self.transitioningDelegate.fadeTransition.shouldHideStatusBar = YES;
    }
    
    __weak typeof(self) welf = self;
    self.transitioningDelegate.willDismissBlock = ^{
        __strong typeof(welf) stelf = welf;
        if (stelf.presentedDocument) {
            [stelf updateDocumentTransitionWithCurrentPageIndex:pdfController.page
                                        andDoublePageModeActive:pdfController.isDoublePageMode];
        }
        
    };
    
    self.transitioningDelegate.documentTransition.animationEndedBlock = ^(BOOL success, TransitionMode mode) {
        if (mode == TransitionModeDismiss) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [welf.collectionView reloadData];
            });
        }
        
    };
    
    self.navigationController.delegate = self.transitioningDelegate;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.navigationController pushViewController:controllerToPresent animated:YES];
        // dirty stuff ... but otherwise double opening will happen
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            welf.isPresentingController = NO;
        });
    });
}

- (UIImage *)targetImageForDocument:(PUBPDFDocument *)pdfDocument page:(NSInteger)page {
    return [PSPDFKit.sharedInstance.cache imageFromDocument:pdfDocument
                                                       page:page
                                                       size:UIScreen.mainScreen.bounds.size
                                                    options:PSPDFCacheOptionDiskLoadSkip|PSPDFCacheOptionRenderSkip|PSPDFCacheOptionMemoryStoreAlways];
}

- (void)updateDocumentTransitionWithCurrentPageIndex:(NSInteger)currentPageIndex
                             andDoublePageModeActive:(BOOL)doublePageModeActive {
    self.transitioningDelegate.documentTransition.targetPosition = [PUBDocumentTransition targetPositionForPageIndex:currentPageIndex
                                                                                                  isDoubleModeActive:doublePageModeActive];
}

#pragma mark - PUBDocumentTransition DataSource

- (UIView *)currentTransitionSourceView {
    [self.collectionView layoutSubviews];
    NSIndexPath *path = [self indexPathForProductID:self.presentedDocument.productID];
    PUBCellView *cell = (PUBCellView *)[self.collectionView cellForItemAtIndexPath:path];
    
    return cell.coverImage;
}

- (UIImage *)currentTransitionImage {
    [self.collectionView layoutSubviews];
    NSIndexPath *path = [self indexPathForProductID:self.presentedDocument.productID];
    PUBCellView *cell = (PUBCellView *)[self.collectionView cellForItemAtIndexPath:path];
    
    return cell.coverImage.image;
}

#pragma mark - KVNProgress configuration

- (KVNProgressConfiguration *)fullScreenBlockingProgressConfiguration {
    KVNProgressConfiguration *configuration = [[KVNProgressConfiguration alloc] init];
    
    configuration.statusFont = [UIFont fontWithName:@"HelveticaNeue-Thin" size:18.0f];
    configuration.circleSize = 110.0f;
    configuration.lineWidth = 1.0f;
    configuration.fullScreen = YES;
    
    return configuration;
}

- (KVNProgressConfiguration *)notifyMessageConfiguration {
    KVNProgressConfiguration *configuration = [[KVNProgressConfiguration alloc] init];
    
    configuration.statusFont = [UIFont fontWithName:@"HelveticaNeue-Thin" size:18.0f];
    configuration.circleSize = 110.0f;
    configuration.lineWidth = 1.0f;
    configuration.fullScreen = NO;
    
    return configuration;
}

@end
