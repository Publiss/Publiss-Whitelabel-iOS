//
//  PUBBugFixFlowLayout.m
//  Publiss
//
//  Created by Denis Andrasec on 24.06.14.
//  Copyright (c) 2014 Publiss GmbH. All rights reserved.
//

#import "PUBBugFixFlowLayout.h"

// Code from: https://openradar.appspot.com/12433891

@implementation PUBBugFixFlowLayout

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

@end
