//
//  PUBPagePreviewViewController.h
//  Publiss
//
//  Copyright (c) 2014 Publiss GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PUBDocument;

@interface PUBPagePreviewViewController : UIViewController

@property (nonatomic, strong) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) NSString *pageName;
@property (nonatomic, assign) NSInteger initialPage;
@property (nonatomic, strong) PUBDocument *document;

@end
