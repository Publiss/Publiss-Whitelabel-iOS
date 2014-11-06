//
//  PUBCellView.m
//  Publiss
//
//  Copyright (c) 2014 Publiss GmbH. All rights reserved.
//

#import "PUBCellView.h"
#import "PUBBadgeView.h"
#import "UIColor+PUBDesign.h"
#import <tgmath.h>

@interface PUBCellView ()
@property (nonatomic, strong) UIView *overlayView;
@end

@implementation PUBCellView

#define DELETE_BUTTON_WIDTH 22.f

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self.contentView addSubview:self.coverImage];
    [self.contentView addSubview:self.badgeView];
    [self.contentView addSubview:self.deleteButton];
    [self.contentView addSubview:self.namedBadgeView];
    [self.contentView addSubview:self.progressView];
    [self bringSubviewToFront:self.progressView];
    [self insertSubview:self.activityIndicator aboveSubview:self.coverImage];
    self.yOffset = 0;
    self.activityIndicator.hidden = YES;
    
    self.contentMode = UIViewContentModeScaleAspectFit;
}

#pragma mark - Custom Getter

- (UIActivityIndicatorView *)activityIndicator
{
    if (!_activityIndicator) {
        _activityIndicator = [UIActivityIndicatorView new];
        _activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        _activityIndicator.color = UIColor.publissPrimaryColor;
        _activityIndicator.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    }
    return _activityIndicator;
}

- (UIButton *)deleteButton {
    if (!_deleteButton) {
        _deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *deleteButtonImage = [UIImage imageNamed:@"delete"];
        deleteButtonImage = [deleteButtonImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [_deleteButton setBackgroundImage:deleteButtonImage forState:UIControlStateNormal];
        _deleteButton.tintColor = [UIColor colorWithRed:0.99f green:0.24f blue:0.22f alpha:1.f];
    }
    return _deleteButton;
}

- (PUBNamedBadgeView *)namedBadgeView {
    if (!_namedBadgeView) {
        _namedBadgeView = [[PUBNamedBadgeView alloc] initWithFrame:[self updatedViewFrame]];
    }
    return _namedBadgeView;
}

- (UIView *)overlayView {
    if (!_overlayView) {
        _overlayView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 50.0f, 50.0f)];
        _overlayView.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.4f];
    }
    return _overlayView;
}

- (UIImageView *)coverImage {
    if (!_coverImage) {
        _coverImage = [[UIImageView alloc] initWithFrame:self.bounds];
        _coverImage.contentMode = UIViewContentModeScaleAspectFit;
        _coverImage.backgroundColor = [UIColor clearColor];
        _coverImage.clipsToBounds = NO;
        
        _coverImage.layer.shadowColor = [UIColor blackColor].CGColor;
        _coverImage.layer.shadowOffset = CGSizeMake(-.3f, 0.f);
        _coverImage.layer.shadowRadius = 1.f;
        _coverImage.layer.shadowOpacity = .2f;
    }
    return _coverImage;
}

- (UIProgressView *)progressView {
    if (!_progressView) {
        _progressView = [[UIProgressView alloc] initWithFrame:CGRectZero];
        _progressView.tintColor = [UIColor publissPrimaryColor];
    }
    return _progressView;
}

- (PUBBadgeView *)badgeView {
    if (!_badgeView) {
        _badgeView = [[PUBBadgeView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 50.0f, 50.0f)];
        
        UIImage *downloadImage = [UIImage imageNamed:@"download"];
        downloadImage = [downloadImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        self.badgeView.icon = downloadImage;
        self.badgeView.iconOffset = CGSizeMake(-5.0f, 5.0f);
        self.badgeView.fillColor = [UIColor publissPrimaryColor];
    }
    return _badgeView;
}

#pragma mark - Custom Setter

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    
    if (highlighted) {
        [self.contentView addSubview:self.overlayView];
        [self.contentView insertSubview:self.overlayView aboveSubview:self.coverImage];
    } else {
        [self.overlayView removeFromSuperview];
    }
    [self setNeedsDisplay];
}

- (void)setShowDeleteButton:(BOOL)showDeleteButton {
    _showDeleteButton = showDeleteButton;
    self.deleteButton.hidden = !showDeleteButton;
}

- (void)setBadgeViewHidden:(BOOL)hidden animated:(BOOL)animated {
    [self.badgeView setNeedsDisplay];
    if (animated && !hidden) {
        self.badgeView.hidden = hidden;
        self.badgeView.alpha = 0.f;
        [UIView animateWithDuration:.25f animations:^{
            self.badgeView.alpha = 1.f;
        } completion:NULL];
    } else {
        self.badgeView.hidden = hidden;
    }
}

#pragma mark - Layout Views

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.contentView.frame =  CGRectIntegral(CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height));
    
    // Resize the views to fit the cover image.
    
    if (self.coverImage.image) {
        self.coverImage.frame = [self coverImageFrame];
        self.coverImage.center = [self coverImageCenter];
        self.coverImage.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.coverImage.bounds].CGPath;
    }
    
    self.overlayView.frame = self.coverImage.frame;
    self.deleteButton.frame = [self deleteButtonFrame];
    self.progressView.frame = [self progressViewFrame];
    self.badgeView.frame = [self badgeViewFrame];
    self.activityIndicator.frame = [self activityIndicatorFrame];
    self.namedBadgeView.frame = [self badgeViewFrame];
}

- (CGRect)coverImageFrame {
    CGFloat width;
    CGFloat height;
    CGFloat ratio = self.coverImage.image.size.width / self.coverImage.image.size.height;
    if (ratio > 1.f) {
        width = __tg_ceil(self.bounds.size.width);
        height = __tg_ceil(self.bounds.size.height / ratio);
    } else {
        width = __tg_ceil(self.bounds.size.width * ratio);
        height = __tg_ceil(self.bounds.size.height);
    }
    return CGRectIntegral(CGRectMake(0.0f, 0.0f, width, height));
}

- (CGPoint)coverImageCenter {
    return CGPointMake(__tg_ceil(self.bounds.size.width / 2.0f),
                       __tg_ceil(self.bounds.size.height - self.coverImage.frame.size.height / 2.0f - self.yOffset));
}

- (CGRect)activityIndicatorFrame {
    return CGRectMake(self.coverImage.center.x - 5.f, self.coverImage.center.y - 5.f, 10.f, 10.f);
}

- (CGRect)updatedViewFrame {
    return CGRectMake(self.bounds.size.width / 2 - 6,
                      self.bounds.size.height + 6,
                      12,
                      12);
}

- (CGRect)badgeViewFrame {
    CGRect frame = self.badgeView.frame;
    frame.origin.x = CGRectGetMaxX(self.coverImage.frame) - self.badgeView.frame.size.width;
    frame.origin.y = self.coverImage.frame.origin.y;
    return frame;
}

- (CGRect)deleteButtonFrame {
    return CGRectIntegral(CGRectMake(self.coverImage.frame.origin.x - (DELETE_BUTTON_WIDTH / 2.f),
                                     self.coverImage.frame.origin.y - (DELETE_BUTTON_WIDTH / 2.f),
                                     DELETE_BUTTON_WIDTH,
                                     DELETE_BUTTON_WIDTH)) ;
}

- (CGRect)progressViewFrame {
    return CGRectIntegral( CGRectMake(self.coverImage.frame.origin.x,
                                      self.coverImage.frame.origin.y - (self.progressView.frame.size.height) +
                                      CGRectGetHeight(self.coverImage.bounds),
                                      CGRectGetWidth(self.coverImage.frame), CGRectGetHeight(self.coverImage.frame)));
}

#pragma mark - Touch Events

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    [super   hitTest:point withEvent:event];
    CGPoint subPoint = [self.deleteButton convertPoint:point fromView:self];
    UIView *result = [self.deleteButton hitTest:subPoint withEvent:event];
    if (result != nil) {
        return result;
    }
    
    if (!self.clipsToBounds && !self.hidden && self.alpha > 0.00000001f) {
        if (result != nil) {
            return result;
        }
    }
    return [super hitTest:point withEvent:event];
}

@end
