//
//  PUBKioskLayout.m
//  Publiss
//
//  Created by Denis Andrasec on 14.10.14.
//  Copyright (c) 2014 Publiss GmbH. All rights reserved.
//

#import "PUBKioskLayout.h"
#import "PUBConstants.h"
#import "PUBImageReusableView.h"

@interface PUBKioskLayout()

@property (nonatomic, strong) NSDictionary *shelfRects;
@end

@implementation PUBKioskLayout

- (id)init {
    self = [super init];
    if (self) {
        [self updateSizesAndSpacings];
        [self registerClass:[PUBImageReusableView class] forDecorationViewOfKind:[PUBImageReusableView kind]];
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
    self.shelfRects = [self calculateShelveRects];
}

- (NSDictionary *)calculateShelveRects {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    
    // Calculate where shelves go in a vertical layout.
    if (self.scrollDirection == UICollectionViewScrollDirectionVertical) {
        NSInteger sectionCount = [self.collectionView numberOfSections];
        
        CGFloat y = 0;
        CGFloat availableWidth = self.collectionViewContentSize.width - (self.sectionInset.left + self.sectionInset.right);
        NSInteger itemsAcross = (NSInteger)floor((availableWidth + self.minimumInteritemSpacing) / (self.itemSize.width + self.minimumInteritemSpacing));
        
        for (int section = 0; section < sectionCount; section++) {
            y += self.headerReferenceSize.height;
            y += self.sectionInset.top;
            
            NSInteger itemCount = [self.collectionView numberOfItemsInSection:section];
            NSInteger rows = (NSInteger)ceilf(itemCount/(float)itemsAcross);
            for (int row = 0; row < rows; row++) {
                
                dictionary[[NSIndexPath indexPathForItem:row inSection:section]] = [NSValue valueWithCGRect:CGRectMake(0, y - self.minimumLineSpacing + 1, self.collectionViewContentSize.width, self.itemSize.height + self.minimumLineSpacing)];
                y += self.itemSize.height;
                
                if (row < rows - 1)
                    y += self.minimumLineSpacing;
            }
            
            y += self.sectionInset.bottom;
            y += self.footerReferenceSize.height;
        }
    }
    
    return [NSDictionary dictionaryWithDictionary:dictionary];
}


- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSArray *array = [super layoutAttributesForElementsInRect:rect];

    for (UICollectionViewLayoutAttributes *attributes in array) {
        attributes.zIndex = 1;
    }
    
    NSMutableArray *newArray = [array mutableCopy];
    
    [self.shelfRects enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if (CGRectIntersectsRect([obj CGRectValue], rect)) {
            UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForDecorationViewOfKind:[PUBImageReusableView kind] withIndexPath:key];
            attributes.frame = [obj CGRectValue];
            attributes.zIndex = 0;
            [newArray addObject:attributes];
        }
    }];
    
    return [NSArray arrayWithArray:newArray];
}


- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewLayoutAttributes *attributes = [super layoutAttributesForItemAtIndexPath:indexPath];
    attributes.zIndex = 1;
    return attributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForDecorationViewOfKind:(NSString *)decorationViewKind atIndexPath:(NSIndexPath *)indexPath {
    id shelfRect = self.shelfRects[indexPath];
    if (!shelfRect)
        return nil;
    UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForDecorationViewOfKind:[PUBImageReusableView kind]
                                                                                                               withIndexPath:indexPath];
    attributes.frame = [shelfRect CGRectValue];
    attributes.zIndex = 0;
    
    return attributes;
}

/*
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
 */

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
