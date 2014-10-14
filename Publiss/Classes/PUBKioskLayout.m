//
//  PUBKioskLayout.m
//  Publiss
//
//  Created by Denis Andrasec on 14.10.14.
//  Copyright (c) 2014 Publiss GmbH. All rights reserved.
//

#import "PUBKioskLayout.h"
#import "PUBConstants.h"

@implementation PUBKioskLayout

- (id)init {
    self = [super init];
    if (self) {
        [self updateSizesAndSpacings];
    }
    return self;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    CGRect oldBounds = self.collectionView.bounds;
    if (!CGSizeEqualToSize(oldBounds.size, newBounds.size)) {
        return YES;
    }
    return NO;
}

- (void)prepareLayout {
    [super prepareLayout];
    [self updateSizesAndSpacings];
}

// Code from: https://openradar.appspot.com/12433891
- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSArray *unfilteredPoses = [super layoutAttributesForElementsInRect:rect];
    id filteredPoses[unfilteredPoses.count];
    NSUInteger filteredPosesCount = 0;
    for (UICollectionViewLayoutAttributes *pose in unfilteredPoses) {
        CGRect frame = pose.frame;
        if (frame.origin.x + frame.size.width <= rect.size.width) {
            filteredPoses[filteredPosesCount++] = pose;
        }
    }
    return [NSArray arrayWithObjects:filteredPoses count:filteredPosesCount];
}

- (void)updateSizesAndSpacings {
    self.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    self.itemSize = PUBIsiPad() ? CGSizeMake(160.0f, 160.0f) : CGSizeMake(140.f, 140.f);
    self.sectionInset = PUBIsiPad() ? UIEdgeInsetsMake(30.f, 30.0f, 30.0f, 30.0f) : UIEdgeInsetsMake(50.f, 15.f, 50.8f, 15.f);
    self.minimumInteritemSpacing = PUBIsiPad() ? 20.0f : 10.0f;
    self.minimumLineSpacing = PUBIsiPad() ? 31.0f : 51.0f;
    
    CGFloat fraction = UIInterfaceOrientationIsPortrait([self orientation]) ? 2 : 3;
    self.headerReferenceSize = CGSizeMake(self.collectionView.bounds.size.width, self.collectionView.bounds.size.width/fraction);
}

- (UIInterfaceOrientation)orientation {
    return [[UIApplication sharedApplication] statusBarOrientation];
}

@end
