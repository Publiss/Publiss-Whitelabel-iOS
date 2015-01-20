//
//  PUBKioskIssueLabel.m
//  Publiss
//
//  Created by Daniel Griesser on 20.01.15.
//  Copyright (c) 2015 Publiss GmbH. All rights reserved.
//

#import "PUBKioskIssueLabel.h"

@implementation PUBKioskIssueLabel

- (void)drawTextInRect:(CGRect)rect {
    [super drawTextInRect:UIEdgeInsetsInsetRect(rect, UIEdgeInsetsMake(2, 5, 2, 5))];
}

- (void)setText:(NSString *)text {
    NSMutableParagraphStyle *style  = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 1.1f;
    NSDictionary *attributtes = @{NSParagraphStyleAttributeName : style};
    self.attributedText = [[NSAttributedString alloc] initWithString:text
                                                          attributes:attributtes];
}

@end
