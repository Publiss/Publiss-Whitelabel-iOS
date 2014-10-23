//
//  PUBiPhonePreviewViewController.m
//  Publiss
//
//  Copyright (c) 2014 Publiss GmbH. All rights reserved.
//

#import "PUBiPhonePreviewViewController.h"
#import "PUBDocument+Helper.h"
#import "UIColor+PUBDesign.h"
#import "PUBConstants.h"

@interface PUBiPhonePreviewViewController () <UINavigationControllerDelegate, UIScrollViewDelegate>

@property (strong, nonatomic) IBOutlet UICollectionView *previewCollectionView;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation PUBiPhonePreviewViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];

    self.previewCollectionView.delegate = self;
    self.previewCollectionView.dataSource = self;
    self.scrollView.delegate = self;
    self.scrollView.bounces = YES;
    self.scrollView.scrollEnabled = YES;
    self.scrollView.showsVerticalScrollIndicator = YES;
    
    self.previewCollectionView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"collectionview_preview_iphone"]];


    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissNavController:)];
    self.navigationItem.leftBarButtonItems = @[doneButton];

    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.barTintColor = [UIColor publissPrimaryColor];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(documentFetchingNotification:) name:PUBDocumentFetcherUpdateNotification object:NULL];
    [self updateUIDownloadState];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    // layout description text to top left corner
    [self.descriptionText sizeToFit];
    CGFloat height = 86 /* Title height */ + 48 /* File info height */ + self.descriptionText.frame.size.height + self.previewCollectionView.frame.size.height;
    self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.bounds), height);
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [NSNotificationCenter.defaultCenter removeObserver:self name:PUBDocumentFetcherUpdateNotification object:NULL];
}


#pragma mark CollectionView FlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(240.f, 240.f);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(16.f, 15.f, 0.f, 15.f);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout *)collectionViewLayout
minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 10.f;
}

#pragma mark - Private

- (void)dismissNavController:(id)sender {
    if ([sender isKindOfClass:UIBarButtonItem.class]) {
        if (!self.presentingViewController.isBeingPresented) 
            [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)updateUIDownloadState {
    switch (self.document.state) {
        case PUBDocumentStateLoading:
            self.navigationItem.title = PUBLocalize(@"Downloading...");
            [self.downloadButton setTitle:PUBLocalize(@"Read") forState:UIControlStateNormal];
            break;
            
        case PUBDocumentStateDownloaded:
            self.navigationItem.title = nil;
            [self.downloadButton setTitle:PUBLocalize(@"Read") forState:UIControlStateNormal];
            break;
            
        case PUBDocumentStateUpdated:
            self.navigationItem.title = nil;
            [self.downloadButton setTitle:PUBLocalize(@"Update") forState:UIControlStateNormal];
            break;
            
        default:
            self.navigationItem.title = nil;
            break;
    }
}

#pragma mark Notifications

- (void)documentFetchingNotification:(NSNotification *)notification {
    if ([notification.userInfo isKindOfClass:NSDictionary.class]) {
        if (notification.userInfo[self.document.productID])
            [self updateUIDownloadState];
    }
}

@end
