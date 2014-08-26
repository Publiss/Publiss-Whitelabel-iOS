//
//  PUBThumbnailGridViewCell.m
//  Publiss
//
//  Copyright (c) 2014 Publiss GmbH. All rights reserved.
//

#import "PUBThumbnailGridViewCell.h"
#import "UIColor+PUBDesign.h"

@implementation PUBThumbnailGridViewCell

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
       self.selectedBackgroundView.backgroundColor = UIColor.publissPrimaryColor;
    }
    return self;
}

@end
