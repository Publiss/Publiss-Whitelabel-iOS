//
//  PUBParentPreviewViewController.h
//  Publiss
//
//  Copyright (c) 2014 Publiss GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PUBDownloadButton.h"
#import "PUBKioskViewController.h"

@class PUBDocument, PUBCellView;

@interface PUBParentPreviewViewController : UIViewController <UICollectionViewDelegate, UICollectionViewDataSource>

@property (strong, nonatomic) PUBKioskViewController *kioskController;

@property (strong, nonatomic) PUBDocument *document;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *descriptionText;
@property (strong, nonatomic) IBOutlet UILabel *fileDescription;
@property (strong, nonatomic) IBOutlet UILabel *descriptionTitle;
@property (strong, nonatomic) IBOutlet PUBDownloadButton *downloadButton;
@property (strong, nonatomic) SKProduct *product;
@property (assign, nonatomic) CGRect oldViewFrame;
@property (strong, nonatomic) UITapGestureRecognizer *recognizer;

- (void)updateUI;
- (void)defineDescriptionText;
- (void)openPDFWithWithDocument:(PUBDocument *)document;

@end
