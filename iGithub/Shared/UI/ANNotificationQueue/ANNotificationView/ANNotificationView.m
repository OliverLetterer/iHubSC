//
//  ANNotificationView.m
//  iGithub
//
//  Created by Oliver Letterer on 12.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "ANNotificationView.h"


@implementation ANNotificationView
@synthesize displayTime=_displayTime;
@synthesize backgroundView=_backgroundView, titleLabel=_titleLabel, detailTextLabel=_detailTextLabel, imageView=_imageView;

#pragma mark - Initialization

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
        self.displayTime = 2.0f;
        self.backgroundColor = [UIColor blackColor];
        
        self.backgroundView = [[ANNotificationViewBackgroundView alloc] initWithFrame:CGRectZero];
        [self addSubview:self.backgroundView];
        
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.titleLabel.textAlignment = UITextAlignmentLeft;
        self.titleLabel.textColor = [UIColor whiteColor];
        self.titleLabel.font = [UIFont boldSystemFontOfSize:21.0f];
        self.titleLabel.backgroundColor = [UIColor clearColor];
        self.titleLabel.shadowColor = [UIColor colorWithWhite:0.0f alpha:0.75f];
        self.titleLabel.shadowOffset = CGSizeMake(0.0f, -2.0f);
        [self addSubview:self.titleLabel];
        
        self.detailTextLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.detailTextLabel.textAlignment = UITextAlignmentLeft;
        self.detailTextLabel.textColor = [UIColor whiteColor];
        self.detailTextLabel.font = [UIFont systemFontOfSize:19.0f];
        self.detailTextLabel.backgroundColor = [UIColor clearColor];
        self.detailTextLabel.shadowColor = [UIColor colorWithWhite:0.0f alpha:0.75f];
        self.detailTextLabel.shadowOffset = CGSizeMake(0.0f, -2.0f);
        [self addSubview:self.detailTextLabel];
        
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.imageView.contentMode = UIViewContentModeCenter;
        [self addSubview:self.imageView];
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            self.titleLabel.font = [UIFont boldSystemFontOfSize:16.0f];
            self.detailTextLabel.font = [UIFont systemFontOfSize:16.0f];
        }
    }
    return self;
}

- (void)layoutSubviews {
    self.backgroundView.frame = CGRectMake(1.0f, 1.0f, CGRectGetWidth(self.bounds)-2.0f, CGRectGetHeight(self.bounds)-2.0f);
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.imageView.frame = CGRectMake(0.0f, 0.0f, 50.0f, 50.0f);
        self.imageView.center = CGPointMake(50.0f, CGRectGetHeight(self.bounds) / 2.0f);
    } else {
        self.imageView.frame = CGRectMake(0.0f, 0.0f, 25.0f, 25.0f);
        self.imageView.center = CGPointMake(25.0f, CGRectGetHeight(self.bounds) / 2.0f);
    }
    
    CGRect frame = self.imageView.frame;
    frame.origin.x += CGRectGetWidth(self.imageView.frame) + 8.0f;
    frame.size.width = CGRectGetWidth(self.bounds) - frame.origin.x;
    frame.origin.y = 20.0f;
    self.titleLabel.frame = frame;
    [self.titleLabel sizeToFit];
    
    frame = self.titleLabel.frame;
    frame.origin.y += CGRectGetHeight(frame) + 8.0f;
    self.detailTextLabel.frame = frame;
    [self.detailTextLabel sizeToFit];
}

#pragma mark - Memory management


@end
