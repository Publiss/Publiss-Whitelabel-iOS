//
//  PUBiPhonePreviewViewController.m
//  Publiss
//
//  Copyright (c) 2014 Publiss GmbH. All rights reserved.
//

#import "PUBPreviewViewController.h"
#import "PUBLanguageTableViewController.h"
#import "PUBDocument+Helper.h"
#import "PUBLanguage.h"
#import "UIColor+PUBDesign.h"
#import "PUBConstants.h"
#import <PublissCore.h>

@interface PUBPreviewViewController () <UINavigationControllerDelegate, UIScrollViewDelegate, PUBLanguageSelectionDelegate>

@property (strong, nonatomic) IBOutlet UICollectionView *previewCollectionView;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation PUBPreviewViewController

#pragma mark - UIViewController

+ (PUBPreviewViewController *)instantiatePreviewController {
    return [[UIStoryboard storyboardWithName:@"PUBPreviewViewController" bundle:nil] instantiateInitialViewController];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];

    self.previewCollectionView.delegate = self;
    self.previewCollectionView.dataSource = self;
    self.scrollView.delegate = self;
    self.scrollView.bounces = YES;
    self.scrollView.scrollEnabled = YES;
    self.scrollView.showsVerticalScrollIndicator = YES;
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissNavController:)];
    self.navigationItem.leftBarButtonItems = @[doneButton];
    
    if (PUBConfig.sharedConfig.preferredLanguage.length > 0 && self.document.language.linkedTag.length > 0) {
        NSArray *documents = [PUBDocument fetchAllSortedBy:@"language.localizedTitle"
                                                 ascending:YES
                                                 predicate:[NSPredicate predicateWithFormat:@"language.linkedTag == %@", self.document.language.linkedTag]];
        
        if (documents.count > 1) {
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:PUBLocalize(@"Languages") style:UIBarButtonItemStylePlain target:self action:@selector(openLanguageSelection)];
        }
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    // layout description text to top left corner
    [self.descriptionText sizeToFit];

    CGFloat height = 86 /* Title height */ + 48 /* File info height */ + self.descriptionText.frame.size.height + self.previewCollectionView.frame.size.height;
    self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.bounds), height);
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
        if (!self.presentingViewController.isBeingPresented) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
}

- (void)openLanguageSelection {
    PUBLanguageTableViewController *languageSelection = [PUBLanguageTableViewController instantiateLanguageSelectionController];
    [languageSelection setupLanguageSelectionForDocument:self.document];
    languageSelection.delegate = self;

    [self.navigationController pushViewController:languageSelection
                                         animated:YES];
}

#pragma mark - PUBLanguageSelectionDelegate

- (void)didSelectLanguageForDocument:(PUBDocument *)document {
    [self openPDFWithWithDocument:document];
}

- (void)didRemoveLanguageForDocument:(PUBDocument *)document {
    [document deleteDocument:nil];
}


@end
