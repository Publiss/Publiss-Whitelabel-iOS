//
//  PUBPreviewViewController.m
//  Publiss
//
//  Copyright (c) 2014 Publiss GmbH. All rights reserved.
//

#import "PUBPreviewViewController.h"
#import "PUBDocument+Helper.h"

@interface PUBPreviewViewController () <PSPDFViewControllerDelegate, UINavigationControllerDelegate>
@property (nonatomic, strong) IBOutlet UICollectionView *previewCollectionView;
@end

@implementation PUBPreviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"preview_background"]];
    [self.previewCollectionView registerNib:[UINib nibWithNibName:@"PreviewCell" bundle:nil]
                 forCellWithReuseIdentifier:@"PreviewCell"];
    
    self.previewCollectionView.delegate = self;
    self.previewCollectionView.dataSource = self;
    [self addMotionEffectForView:self.view withDepthX:20.f withDepthY:20.f];

    self.descriptionText.numberOfLines = 3;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(documentFetchingNotification:) name:PUBDocumentFetcherUpdateNotification object:NULL];
    [self updateUIDownloadState];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if ([self.view.window.gestureRecognizers containsObject:self.recognizer]) {
        [self.view.window removeGestureRecognizer:self.recognizer];
    }
    [NSNotificationCenter.defaultCenter removeObserver:self name:PUBDocumentFetcherUpdateNotification object:NULL];
}

#define Cell_Spacing 15.f

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
   return  CGSizeMake(300.0f, 300.0f);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout *)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(.0f, 20.0f, 0.0f, 20.0f);
}


- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout *)collectionViewLayout
    minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
   return  Cell_Spacing;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout *)collectionViewLayout
    minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return Cell_Spacing;
}



#pragma mark - Motion effect

- (void)addMotionEffectForView:(UIView *)view withDepthX:(CGFloat)depthX withDepthY:(CGFloat)depthY {
    UIInterpolatingMotionEffect *xAxis;
    xAxis =
        [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x"
                                                        type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];

    xAxis.minimumRelativeValue = @(-depthX);
    xAxis.maximumRelativeValue = @(depthX);

    UIInterpolatingMotionEffect *yAxis;
    yAxis = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y"
                                                            type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];

    yAxis.minimumRelativeValue = @(-depthY);
    yAxis.maximumRelativeValue = @(depthY);

    UIMotionEffectGroup *group = [[UIMotionEffectGroup alloc] init];
    group.motionEffects = @[ xAxis, yAxis ];

    [view addMotionEffect:group];
}

#pragma mark Notifications

- (void)documentFetchingNotification:(NSNotification *)notification {
    if ([notification.userInfo isKindOfClass:NSDictionary.class]) {
        if (notification.userInfo[self.document.productID])
            [self updateUIDownloadState];
    }
}

#pragma mark Helpers

- (void)updateUIDownloadState {
    switch (self.document.state) {
        case PUBDocumentStateLoading:
            [self.downloadButton setTitle:PUBLocalize(@"Read") forState:UIControlStateNormal];
            break;
            
        case PUBDocumentStateDownloaded:
            [self.downloadButton setTitle:PUBLocalize(@"Read") forState:UIControlStateNormal];
            break;
            
        case PUBDocumentStateUpdated:
            [self.downloadButton setTitle:PUBLocalize(@"Read") forState:UIControlStateNormal];
            break;
            
        default:
            break;
    }
}

@end
