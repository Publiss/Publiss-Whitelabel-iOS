//
//  CustomLinkAnnotationView.m
//  Publiss
//
//  Copyright (c) 2014 Publiss GmbH. All rights reserved.
//

#import "PUBLinkAnnotationView.h"
#import "UIColor+PUBDesign.h"

@implementation PUBLinkAnnotationView

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        self.borderColor = [UIColor clearColor];
        self.strokeWidth = 0.0f;
        self.hideSmallLinks = NO;
        
        // animate annotation to highlight themself
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:.6 animations:^{
                self.backgroundColor = [[UIColor publissPrimaryColor] colorWithAlphaComponent:0.3f];
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:.4 delay:1 options:0 animations:^{
                    self.backgroundColor = [UIColor clearColor];
                } completion:NULL];
            }];
        });
    }
    return self;
}

- (UIButton *)createActivationButton {
    return [super createActivationButton];
}

@end
