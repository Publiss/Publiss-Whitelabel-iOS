//
//  PUBUserLoginFieldTableViewCell.h
//  Publiss
//
//  Created by Lukas Korl on 16/12/14.
//  Copyright (c) 2014 Publiss GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PUBUserLoginFieldTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UITextField *defaultTextField;

- (instancetype)setupFieldWithTitle:(NSString *)title andParameterName:(NSString *)parameterName;
- (NSString *)getParameterName;
- (NSString *)getParameterValue;

@end
