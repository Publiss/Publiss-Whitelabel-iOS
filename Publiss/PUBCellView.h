//
//  PUBCellView.h
//  Publiss
//
//  Copyright (c) 2014 Publiss GmbH. All rights reserved.
//

#import "PUBDocument+Helper.h"
#import "PUBCoverImageCell.h"

@class PUBDocument, PUBBadgeView, PUBUpdatedView;

@interface PUBCellView : UICollectionViewCell <PUBCoverImageCell>
@property (strong, nonatomic) UIImageView *coverImage;
@property (strong, nonatomic) PUBDocument *document;
@property (assign, nonatomic) BOOL showDeleteButton;
@property (strong, nonatomic) UIButton *deleteButton;
@property (strong, nonatomic) UIProgressView *progressView;
@property (strong, nonatomic) PUBBadgeView *badgeView;
@property (nonatomic, strong) PUBUpdatedView *updatedView;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;

- (void)setupCellForDocument:(PUBDocument *)document;
- (void)setBadgeViewHidden:(BOOL)hidden animated:(BOOL)animated;

@end
