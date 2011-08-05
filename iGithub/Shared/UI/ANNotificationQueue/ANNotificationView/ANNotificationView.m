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

#pragma mark - setters and getters

- (CGFloat)textOffsetX {
    CGFloat offset = 0.0f;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        offset = 75.0f + 8.0f;
    } else {
        offset = 38.0f + 8.0f;
    }
    
    return offset;
}

- (CGFloat)textOffsetY {
    return 20.0f;
}

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
        self.titleLabel.numberOfLines = 0;
        self.titleLabel.lineBreakMode = UILineBreakModeWordWrap;
        [self addSubview:self.titleLabel];
        
        self.detailTextLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.detailTextLabel.textAlignment = UITextAlignmentLeft;
        self.detailTextLabel.textColor = [UIColor whiteColor];
        self.detailTextLabel.font = [UIFont systemFontOfSize:19.0f];
        self.detailTextLabel.backgroundColor = [UIColor clearColor];
        self.detailTextLabel.shadowColor = [UIColor colorWithWhite:0.0f alpha:0.75f];
        self.detailTextLabel.shadowOffset = CGSizeMake(0.0f, -2.0f);
        self.detailTextLabel.numberOfLines = 0;
        self.detailTextLabel.lineBreakMode = UILineBreakModeWordWrap;
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
    
    CGFloat textOffsetX = self.textOffsetX;
    CGFloat textOffsetY = self.textOffsetY;
    CGSize containerSize = CGSizeMake(CGRectGetWidth(self.bounds) - textOffsetX - 5.0f, MAXFLOAT);
    
    CGSize titleSize = [_titleLabel sizeThatFits:containerSize];
    _titleLabel.frame = CGRectMake(textOffsetX, textOffsetY, titleSize.width, titleSize.height);
    
    CGSize descriptionSize = [_detailTextLabel sizeThatFits:containerSize];
    CGFloat descriptionOffsetY = CGRectGetHeight(_titleLabel.frame) + 5.0f + _titleLabel.frame.origin.y;
    _detailTextLabel.frame = CGRectMake(textOffsetX, descriptionOffsetY, descriptionSize.width, descriptionSize.height);
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGFloat textOffsetX = self.textOffsetX;
    CGFloat textOffsetY = self.textOffsetY;
    CGSize containerSize = CGSizeMake(size.width - textOffsetX - 5.0f, size.height - 2.0f*textOffsetY);
    
    CGSize titleSize = [_titleLabel sizeThatFits:containerSize];
    
    CGSize descriptionSize = [_detailTextLabel sizeThatFits:containerSize];
    
    CGSize returnSize = CGSizeMake(size.width, titleSize.height + descriptionSize.height + 2.0f*textOffsetY + 5.0f);
    
    return returnSize;
}

@end
