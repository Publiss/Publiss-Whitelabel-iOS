//  PUBDownloadButton.m
//  Publiss
//
//  Copyright (c) 2014 Publiss GmbH. All rights reserved.
//

#import "PUBDownloadButton.h"
#import "PUBDocument+Helper.h"
#import "UIColor+PUBDesign.h"
#import "IAPController.h"


@interface PUBDownloadButton ()
@property (strong, nonatomic) PUBDocument *document;

@end

@implementation PUBDownloadButton


- (void)awakeFromNib {
    [super awakeFromNib];
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.activityIndicator.color = [UIColor publissPrimaryColor];
    [self insertSubview:self.activityIndicator aboveSubview:self.titleLabel];

    self.opaque = NO;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    self.layer.masksToBounds = YES;
    self.layer.borderWidth = 1.5f;
    self.layer.cornerRadius = 3.9f;
    self.layer.borderColor = self.color.CGColor;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.activityIndicator.center = CGPointMake(self.frame.size.width / 2.f, self.frame.size.height / 2.f);
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [self setTitleColor:self.color forState:UIControlStateNormal];
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    self.backgroundColor = highlighted ? [UIColor publissPrimaryColor] : [UIColor clearColor];
}

- (void)showActivityIndicator {
    self.userInteractionEnabled = NO;
    self.titleLabel.alpha = .0f;
    [self.activityIndicator startAnimating];
}

- (void)hideActivityIndicator {
    self.userInteractionEnabled = YES;
    
    [UIView animateWithDuration:.25f animations:^{
        self.titleLabel.alpha = 1.f;
    } completion:^(BOOL finished) {
        [self.activityIndicator stopAnimating];
    }];
}

#pragma mark - Private

- (void)setupDownloadButtonWithPUBDocument:(PUBDocument *)document {
    self.document = document;
    switch (self.document.state) {
        case PUBDocumentStateDownloaded:
            [self enableReading];
            break;
            
        case PUBDocumentStateOnline: {
            if (!document.paid || [IAPController.sharedInstance hasPurchased:document.productID]) {
                [self enableReading];
            }
                [self hideActivityIndicator];
            }
            break;
            
        case PUBDocumentPurchased:
            [self enableReading];
            break;
            
        default:
            break;
    }
}

- (void)enableReading {
    [self setTitle:PUBLocalize(@"Read") forState:UIControlStateNormal];
    [self hideActivityIndicator];
}

@end
