//
//  PUBKioskViewController.h
//  Publiss
//
//  Copyright (c) 2014 Publiss GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PUBDocument;

@interface PUBKioskViewController : UICollectionViewController

+ (PUBKioskViewController *)kioskViewController;
+ (PUBKioskViewController *)kioskViewControllerWithStoryboardName:(NSString *)storyboard;

@property (nonatomic, assign) BOOL shouldRetrieveDocuments;

- (void)refreshDocumentsWithActivityViewAnimated:(BOOL)animated;
- (void)presentDocument:(PUBDocument *)document;

@end
