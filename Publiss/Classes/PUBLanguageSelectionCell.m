//
//  PUBLanguageSelectionCell.m
//  Publiss
//
//  Created by Lukas Korl on 15/01/15.
//  Copyright (c) 2015 Publiss GmbH. All rights reserved.
//

#import "PUBLanguageSelectionCell.h"
#import "UIColor+PUBDesign.h"
#import "UIImage+PUBTinting.h"
#import "PUBDocument+Helper.h"

@implementation PUBLanguageSelectionCell

- (void)awakeFromNib {
    // Initialization code
    
    [self.downloadButton setTintColor:[UIColor publissPrimaryColor]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark -

- (void)setupCellForDocument:(PUBDocument *)document {
    UIButton *readButton = self.readButton;
    UIButton *downloadButton = self.downloadButton;
    
    if (document.state == PUBDocumentStateDownloaded) {
        readButton.hidden = NO;
        readButton.tintColor = [UIColor publissPrimaryColor];
        readButton.titleLabel.text = PUBLocalize(@"Read");
        downloadButton.hidden = YES;
    }
    else {
        readButton.hidden = YES;
        downloadButton.hidden = NO;
        UIImage *tintedImage = [downloadButton.imageView.image imageTintedWithColor:[UIColor publissPrimaryColor] fraction:0];
        [downloadButton setImage:tintedImage forState:UIControlStateNormal];
        [downloadButton setImage:tintedImage forState:UIControlStateHighlighted];
    }
}

@end
