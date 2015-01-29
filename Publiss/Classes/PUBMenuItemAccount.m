//
//  PUBMenuItemAccount.m
//  Publiss
//
//  Created by Lukas Korl on 17/12/14.
//  Copyright (c) 2014 Publiss GmbH. All rights reserved.
//

#import "PUBMenuItemAccount.h"
#import "PUBAuthentication.h"
#import "UIColor+PUBDesign.h"
#import "UIImage+PUBTinting.h"

@interface PUBMenuItem()



@end

@implementation PUBMenuItemAccount

- (instancetype)init {
    self = [super init];
    
    if (self) {
        
        self.icon = [[UIImage imageNamed:@"profile"] imageTintedWithColor:[UIColor publissSecondaryColor] fraction:0.f];
        self.loggedOutTitle = PUBLocalize(@"Login");
        self.loggedInTitle = PUBLocalize(@"Logout");
        
        self.loggedInSubTitle = [[PUBAuthentication.sharedInstance getMetadata] objectForKey:PUBAuthentication.sharedInstance.menuItemAccountField];
        
        __weak typeof(self) welf = self;
        self.actionBlock = ^() {
            __strong typeof(welf) sself = welf;
            if ([PUBAuthentication.sharedInstance isLoggedIn]) {
                if (sself.actionBlockLogout) {
                    sself.actionBlockLogout();
                }
            }
            else {
                if (sself.actionBlockLogin) {
                    sself.actionBlockLogin();
                }
            }
        };
    }

    return self;
}

- (NSAttributedString *)attributedTitle {
    NSString *title = [PUBAuthentication.sharedInstance isLoggedIn] ? self.loggedInTitle : self.loggedOutTitle;
    NSString *subtitle = [PUBAuthentication.sharedInstance isLoggedIn] ? self.loggedInSubTitle : self.loggedOutSubTitle;
    
    if (subtitle.length > 0) {
        NSUInteger titleEndIndex = title.length;
        title = [NSString stringWithFormat:@"%@ %@", title, subtitle];

        NSMutableAttributedString *formattedTitle = [[NSMutableAttributedString alloc] initWithString:title];
        
        [formattedTitle addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-Thin" size:12.0f] range:NSMakeRange(titleEndIndex + 1, title.length-titleEndIndex-1)];
        
        return formattedTitle;
    }
    
    NSMutableAttributedString *attributedTitle = [[NSMutableAttributedString alloc] initWithString:title];
    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
    [paragraph setAlignment:NSTextAlignmentLeft];
    [paragraph setLineBreakMode:NSLineBreakByTruncatingHead];
    [attributedTitle addAttribute:NSParagraphStyleAttributeName value:paragraph range:NSMakeRange(0, [attributedTitle length])];
    
    return attributedTitle;
}

@end
