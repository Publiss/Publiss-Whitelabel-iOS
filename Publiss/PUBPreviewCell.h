//
//  PUBPreviewCell.h
//  Publiss
//
//  Copyright (c) 2014 Publiss GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PUBCoverImageCell.h"

@class PUBDocument;
@class PUBCenteredScrollView;

@interface PUBPreviewCell : UICollectionViewCell <PUBCoverImageCell, UIScrollViewDelegate>

@property (weak, nonatomic) PUBDocument *document;
@property (strong, nonatomic) UIImageView *previewImageView;
@property (strong, nonatomic) IBOutlet PUBCenteredScrollView *scrollView;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;

- (void)enableZooming;

@end
