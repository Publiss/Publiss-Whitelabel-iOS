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
#import "PUBLanguage.h"
#import "PUBConfig.h"

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
        [readButton setTitle:PUBLocalize(@"Open") forState:UIControlStateNormal];
        downloadButton.hidden = YES;
    }
    else {
        readButton.hidden = YES;
        downloadButton.hidden = NO;
        UIImage *tintedImage = [downloadButton.imageView.image imageTintedWithColor:[UIColor publissPrimaryColor] fraction:0];
        [downloadButton setImage:tintedImage forState:UIControlStateNormal];
    }
    
    NSArray *preferredLanguageDocuments = [PUBDocument fetchAllSortedBy:@"language.localizedTitle"
                                             ascending:YES
                                             predicate:[NSPredicate predicateWithFormat:@"language.linkedTag == %@ AND language.languageTag == %@", document.language.linkedTag, PUBConfig.sharedConfig.preferredLanguage]];
    
    NSMutableAttributedString *languageTitle = [[NSMutableAttributedString alloc] initWithString:document.language.localizedTitle];
    if (PUBConfig.sharedConfig.preferredLanguage.length > 0 && [document.language.languageTag isEqualToString:PUBConfig.sharedConfig.preferredLanguage]) {
        NSMutableAttributedString *postfix = [NSMutableAttributedString.alloc initWithString:[NSString stringWithFormat:@" (%@)", PUBLocalize(@"Default")]];
        [postfix addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor] range:NSMakeRange(0,postfix.length)];
        [languageTitle appendAttributedString:postfix];
    }
    else if (preferredLanguageDocuments.count == 0 && PUBConfig.sharedConfig.fallbackLanguage.length > 0 && [document.language.languageTag isEqualToString:PUBConfig.sharedConfig.fallbackLanguage]) {
        NSMutableAttributedString *postfix = [NSMutableAttributedString.alloc initWithString:[NSString stringWithFormat:@" (%@)", PUBLocalize(@"Default")]];
        [postfix addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor] range:NSMakeRange(0,postfix.length)];
        [languageTitle appendAttributedString:postfix];
    }
    [self.textLabel setAttributedText:languageTitle];
}

@end
