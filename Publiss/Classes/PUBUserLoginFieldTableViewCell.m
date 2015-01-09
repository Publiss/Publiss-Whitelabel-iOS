//
//  PUBUserLoginFieldTableViewCell.m
//  Publiss
//
//  Created by Lukas Korl on 16/12/14.
//  Copyright (c) 2014 Publiss GmbH. All rights reserved.
//

#import "PUBUserLoginFieldTableViewCell.h"

@interface PUBUserLoginFieldTableViewCell ()
@property (nonatomic, strong) NSString *parameterName;
@end

@implementation PUBUserLoginFieldTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - Setup functions

- (instancetype)setupFieldWithTitle:(NSString *)title andParameterName:(NSString *)parameterName
{
    if (self.defaultTextField) {
        [self.defaultTextField setPlaceholder:title];
    }
    
    self.parameterName = parameterName;
    return self;
}

#pragma mark - Layout

- (UIEdgeInsets)layoutMargins {
    return UIEdgeInsetsMake(0, 0, 0, -15.0f);
}

#pragma mark - Internal functions

- (NSString *)getParameterName
{
    return self.parameterName;
}

- (NSString *)getParameterValue
{
    return self.defaultTextField.text;
}

@end
