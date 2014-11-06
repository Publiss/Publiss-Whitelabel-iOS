//
//  PUBCellView.h
//  Publiss
//
//  Copyright (c) 2014 Publiss GmbH. All rights reserved.
//

#import "PUBCoverImageCell.h"
#import "PUBBadgeView.h"
#import "PUBNamedBadgeView.h"

@class PUBDocument;

@interface PUBCellView : UICollectionViewCell <PUBCoverImageCell>

@property (strong, nonatomic) UIImageView *coverImage;
@property (assign, nonatomic) BOOL showDeleteButton;
@property (strong, nonatomic) UIButton *deleteButton;
@property (strong, nonatomic) UIProgressView *progressView;
@property (strong, nonatomic) PUBBadgeView *badgeView;
@property (strong, nonatomic) PUBNamedBadgeView *namedBadgeView;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
@property (assign, assign) CGFloat yOffset;
- (void)setBadgeViewHidden:(BOOL)hidden animated:(BOOL)animated;

@end
