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
    return YES;
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
            UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForDecorationViewOfKind:[PUBImageReusableView kind] atIndexPath:key];
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

- (void)updateSizesAndSpacings {
    self.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    self.itemSize = PUBIsiPad() ? CGSizeMake(160.0f, 160.0f) : CGSizeMake(140.f, 140.f);
    // the bottom inset is 0 because it gets set in the content inset below
    self.sectionInset = PUBIsiPad() ? UIEdgeInsetsMake(30.f, 30.0f, 0, 30.0f) : UIEdgeInsetsMake(50.f, 15.f, 0, 15.f);
    self.minimumInteritemSpacing = PUBIsiPad() ? 20.0f : 10.0f;
    self.minimumLineSpacing = PUBIsiPad() ? 46.0f : 64.0f;
    
    CGFloat fraction = UIInterfaceOrientationIsPortrait([self orientation]) ? 2 : 3;
    
    if (self.showsHeader) {
        self.headerReferenceSize = CGSizeMake(self.collectionView.bounds.size.width, self.collectionView.bounds.size.width/fraction);
    }
    else {
        self.headerReferenceSize = CGSizeZero;
    }
    
    if (self.calculateShelveRects.count) {
        self.footerReferenceSize = CGSizeMake(self.collectionView.bounds.size.width, self.collectionView.bounds.size.height);
        [self.collectionView setContentInset:UIEdgeInsetsMake(self.collectionView.contentInset.top, self.collectionView.contentInset.right, -self.footerReferenceSize.height + (PUBIsiPad() ? 30.0f : 50.8f), self.collectionView.contentInset.left)];
    }
}

- (UIInterfaceOrientation)orientation {
    return [[UIApplication sharedApplication] statusBarOrientation];
}

@end
