//
//  PUBScaleTransition.h
//  Publiss
//
//  Copyright (c) 2014 Publiss GmbH. All rights reserved.
//

#import "PUBBaseTransition.h"
#import "PUBCoverImageCell.h"
#import "PUBPageView.h"

@interface PUBScaleTransition : PUBBaseTransition

@property (nonatomic, strong) UICollectionViewCell<PUBCoverImageCell> *cell;
@property (nonatomic, assign) BOOL modal;
@property (nonatomic, strong) UIView *dimView;
@property (nonatomic, strong) PUBPageView *pageView;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UINavigationBar *navigationBar;
@property (nonatomic, strong) UIImage *targetImage;
@property (nonatomic, assign) CGRect magazinePageFrame;

@end
