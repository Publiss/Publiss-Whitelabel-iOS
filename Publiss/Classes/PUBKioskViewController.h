//
//  PUBKioskViewController.h
//  Publiss
//
//  Copyright (c) 2014 Publiss GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PUBMainViewController, PUBDocument, PUBCellView;

@interface PUBKioskViewController : UICollectionViewController

@property (nonatomic, assign) BOOL shouldRetrieveDocuments;
- (void)refreshDocumentsWithActivityViewAnimated:(BOOL)animated;
- (void)presentDocument:(PUBDocument *)document;

+ (PUBKioskViewController *)kioskViewController;

@end
