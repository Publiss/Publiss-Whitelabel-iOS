//
//  PUBCellView.m
//  Publiss
//
//  Copyright (c) 2014 Publiss GmbH. All rights reserved.
//

#import "PUBCellView.h"
#import "PUBBadgeView.h"
#import "PUBUpdatedView.h"
#import "UIColor+Design.h"
#import <tgmath.h>

@interface PUBCellView ()
@property (nonatomic, strong) NSDictionary *documentProgress;
@property (nonatomic, strong) UIView *overlayView;

@end

@implementation PUBCellView

#define DELETE_BUTTON_WIDTH 22.f
#define Y_OFFSET 0.0f

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setupViews];
    self.contentMode = UIViewContentModeScaleAspectFit;
    
    NSNotificationCenter *dnc = NSNotificationCenter.defaultCenter;
    [dnc addObserver:self selector:@selector(documentFetcherDidUpdateNotification:) name:PUBDocumentFetcherUpdateNotification object:NULL];
    [dnc addObserver:self selector:@selector(documentPurchasedNotification:) name:PUBDocumentPurchaseFinishedNotification object:nil];
}

- (void)setupViews {
    self.deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *deleteButtonImage = [UIImage imageNamed:@"delete"];
    deleteButtonImage = [deleteButtonImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.deleteButton setBackgroundImage:deleteButtonImage forState:UIControlStateNormal];
    self.deleteButton.tintColor = [UIColor colorWithRed:0.99f green:0.24f blue:0.22f alpha:1.f];
    
    [self.contentView addSubview:self.coverImage];
    [self.contentView addSubview:self.badgeView];
    [self.contentView addSubview:self.deleteButton];
    [self.contentView addSubview:self.updatedView];
    
    self.coverImage.clipsToBounds = NO;
    
    self.progressView.tintColor = [UIColor publissPrimaryColor];
    [self.contentView addSubview:self.progressView];
    [self bringSubviewToFront:self.progressView];
    self.coverImage.backgroundColor = UIColor.clearColor;
    
    // activity indicator
    self.activityIndicator = [UIActivityIndicatorView new];
    self.activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    self.activityIndicator.color = UIColor.publissPrimaryColor;
    self.activityIndicator.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    [self insertSubview:self.activityIndicator aboveSubview:self.coverImage];
    
    self.activityIndicator.hidden = YES;
}

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self name:PUBDocumentFetcherUpdateNotification object:nil];
    [NSNotificationCenter.defaultCenter removeObserver:self name:PUBDocumentPurchaseFinishedNotification object:nil];
}

#pragma mark - Custom Getter

- (PUBUpdatedView *)updatedView {
    if (!_updatedView) {
        _updatedView = [[PUBUpdatedView alloc] initWithFrame:[self updatedViewFrame]];
    }
    return _updatedView;
}

- (UIView *)overlayView {
    if (!_overlayView) {
        _overlayView = [[UIView alloc] initWithFrame:CGRectZero];
        _overlayView.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.4f];
    }
    return _overlayView;
}

- (UIImageView *)coverImage {
    if (!_coverImage) {
        _coverImage = [[UIImageView alloc] initWithFrame:self.bounds];
        _coverImage.contentMode = UIViewContentModeScaleAspectFit;
        
        _coverImage.layer.shadowColor = [UIColor blackColor].CGColor;
        _coverImage.layer.shadowOffset = CGSizeMake(-.3f, 0.f);
        _coverImage.layer.shadowRadius = 1.f;
        _coverImage.layer.shadowOpacity = .2f;
    }
    return _coverImage;
}

- (UIProgressView *)progressView {
    if (!_progressView) {
        self.progressView = [[UIProgressView alloc] initWithFrame:CGRectZero];
    }
    return _progressView;
}

- (PUBBadgeView *)badgeView {
    if (!_badgeView) {
        self.badgeView = [[PUBBadgeView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 50.0f, 50.0f)];
        
        UIImage *downloadImage = [UIImage imageNamed:@"download"];
        downloadImage = [downloadImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        self.badgeView.icon = downloadImage;
        self.badgeView.iconOffset = CGSizeMake(-5.0f, 5.0f);
        self.badgeView.fillColor = [UIColor publissPrimaryColor];
    }
    return _badgeView;
}

- (CGRect)updatedViewFrame {
    return CGRectMake(self.bounds.size.width / 2 - 6,
                      self.bounds.size.height + 6,
                      12,
                      12);
}

- (void)setupCellForDocument:(PUBDocument *)document {
    self.document = document;
    self.deleteButton.hidden = YES;
    self.badgeView.hidden = YES;
    self.updatedView.hidden = YES;
    
    switch (document.state) {
        case PUBDocumentStateOnline:
            [self documentOnline];
            break;
        case PUBDocumentStateUpdated:
            [self documentUpdated];
            break;
        case PUBDocumentStateDownloaded:
            [self documentDownloaded];
            break;
        case PUBDocumentStateLoading:
            [self documentLoading];
            break;
        case PUBDocumentPurchased:
            [self documentPurchased];
            break;
    }
}

- (void)documentOnline {
    self.progressView.hidden = YES;
}

- (void)documentUpdated {
    self.progressView.hidden = YES;
    self.updatedView.hidden = NO;
}

- (void)documentDownloaded {
    self.progressView.hidden = YES;
}

- (void)documentLoading {
    self.progressView.hidden = NO;
}

- (void)documentPurchased {
    self.badgeView.fillColor = [UIColor lightGrayColor];
}

#pragma mark layout UI items

- (void)layoutSubviews {
    [super layoutSubviews];

    self.contentView.frame =  CGRectIntegral(CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height));

    // resize the image view proportionally to fit the cover image
    if (self.coverImage.image != nil) {
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

        self.coverImage.frame = CGRectIntegral(CGRectMake(0.0f, 0.0f, width, height));
        self.coverImage.center =
             CGPointMake(__tg_ceil(self.bounds.size.width / 2.0f),
                        __tg_ceil(self.bounds.size.height - self.coverImage.frame.size.height / 2.0f - Y_OFFSET));
    }
    
    self.overlayView.frame = self.coverImage.frame;
    
    // align delete button with cover image
    self.deleteButton.frame =
    CGRectIntegral(CGRectMake(self.coverImage.frame.origin.x - (DELETE_BUTTON_WIDTH / 2.f),
                              self.coverImage.frame.origin.y - (DELETE_BUTTON_WIDTH / 2.f), DELETE_BUTTON_WIDTH, DELETE_BUTTON_WIDTH)) ;
    
    // align download progress bar with cover image
    self.progressView.frame = CGRectIntegral( CGRectMake(self.coverImage.frame.origin.x,
                                                         self.coverImage.frame.origin.y - (self.progressView.frame.size.height) +
                                                         CGRectGetHeight(self.coverImage.bounds),
                                                         CGRectGetWidth(self.coverImage.frame), CGRectGetHeight(self.coverImage.frame)));
    
    // align badge view to be in top right of cover image
    CGRect frame = self.badgeView.frame;
    frame.origin.x = CGRectGetMaxX(self.coverImage.frame) - self.badgeView.frame.size.width;
    frame.origin.y = self.coverImage.frame.origin.y;
    self.badgeView.frame = frame;
    
    self.activityIndicator.frame = CGRectMake(self.coverImage.center.x - 5.f, self.coverImage.center.y - 5.f, 10.f, 10.f);
    
    self.coverImage.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.coverImage.bounds].CGPath;
    
    self.updatedView.frame = [self updatedViewFrame];
}

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

- (void)setShowDeleteButton:(BOOL)showDeleteButton {
    _showDeleteButton = showDeleteButton;
    _deleteButton.hidden = !showDeleteButton;
}

- (void)setBadgeViewHidden:(BOOL)hidden animated:(BOOL)animated {
    if (self.document.state == PUBDocumentPurchased) {
        self.badgeView.fillColor = [UIColor lightGrayColor];
    }
    [self.badgeView setNeedsDisplay];
    
    self.badgeView.alpha = animated ? 0.f : 1.f;
    self.badgeView.hidden = hidden;
    if (!self.badgeView.hidden && animated) {
        [UIView animateWithDuration:.25f animations:^{
            self.badgeView.alpha = 1.f;
        } completion:NULL];
    }
    
}

#pragma mark Notification

- (void)documentPurchasedNotification:(NSNotification *)notification {
    if (notification.userInfo[@"purchased_document"]) {
        PUBDocument *document = notification.userInfo[@"purchased_document"];
        if ([self.document.productID isEqualToString:document.productID])
            [self documentPurchased];
            [self setNeedsDisplay];
    }
}


- (void)documentFetcherDidUpdateNotification:(NSNotification *)notification {
    if ([notification.userInfo[self.document.productID] count] && self.document.state == PUBDocumentStateLoading) {
        self.documentProgress = notification.userInfo[self.document.productID];
        self.document.downloadProgress = [self.documentProgress[@"totalProgress"] floatValue];
        [self handleProgress];
    }
}

- (void)handleProgress {
    self.badgeView.hidden = YES;
    self.updatedView.hidden = YES;
    self.progressView.hidden = NO;
    self.progressView.progress = self.document.downloadProgress;
    if (self.document.downloadProgress >= 1.0f) {
        [self downloadCompleted:^{
            [NSNotificationCenter.defaultCenter postNotificationName:PUBDocumentDownloadFinished object:nil userInfo:@{@"productID": self.document.productID}];
        }];
    }
}

- (void)downloadCompleted:(void(^)())completionBLock {
    if ((self.document.state == PUBDocumentStateLoading)) {
        self.progressView.progress = 0.f;
        self.progressView.hidden = YES;
        self.badgeView.hidden = YES;
        self.coverImage.alpha = 1.0f;
    }
    if (completionBLock) completionBLock();
}



@end
