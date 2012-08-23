//
//  GHPDefaultTableViewCell.m
//  iGithub
//
//  Created by Oliver Letterer on 24.06.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHPDefaultTableViewCell.h"
#import "GHPDefaultTableViewCellBackgroundView.h"
#import <objc/runtime.h>

@interface GHPDefaultTableViewCell (SectionLocation)

- (void)setSectionLocation:(int)location animated:(BOOL)animated;
- (void)setSectionLocation:(int)location;

@end

@implementation GHPDefaultTableViewCell
@synthesize customStyle=_customStyle, myBackgroundView=_myBackgroundView, mySelectedBackgroundView=_mySelectedBackgroundView;

#pragma mark - setters ans getters

- (void)setCustomStyle:(GHPDefaultTableViewCellStyle)customStyle {
    if (_customStyle != customStyle) {
        _customStyle = customStyle;
        self.myBackgroundView.customStyle = _customStyle;
        self.mySelectedBackgroundView.customStyle = _customStyle;
    }
}

- (void)setAccessoryType:(UITableViewCellAccessoryType)accessoryType {
    if (accessoryType != self.accessoryType) {
        [super setAccessoryType:accessoryType];
        if (accessoryType == UITableViewCellAccessoryDisclosureIndicator) {
            UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"UITableViewCellAccessoryDisclosureIndicatorOriginal.png"] ];
            imageView.contentMode = UIViewContentModeCenter;
            self.accessoryView = imageView;
        } else {
            self.accessoryView = nil;
        }
    }
}

- (void)setSectionLocation:(int)location animated:(BOOL)animated
{
    self.customStyle = location;
}

- (void)setSectionLocation:(int)location
{
    self.customStyle = location;
}

#pragma mark - Initialization

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        // Initialization code
        self.myBackgroundView = [[GHPDefaultTableViewCellBackgroundView alloc] init];
        self.backgroundView = self.myBackgroundView;
        
        self.mySelectedBackgroundView = [[GHPDefaultTableViewCellBackgroundView alloc] init];
        self.mySelectedBackgroundView.colors = [NSArray arrayWithObjects:
                                                (__bridge id)[UIColor colorWithRed:252.0f/255.0f green:252.0f/255.0f blue:246.0f/255.0f alpha:1.0].CGColor, 
                                                (__bridge id)[UIColor colorWithRed:241.0f/255.0f green:242.0f/255.0f blue:222.0f/255.0f alpha:1.0].CGColor,
                                                nil];
        self.selectedBackgroundView = self.mySelectedBackgroundView;
        
        self.textLabel.backgroundColor = [UIColor clearColor];
        self.textLabel.highlightedTextColor = [UIColor blackColor];
        self.textLabel.shadowColor = [UIColor whiteColor];
        self.textLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
        
        self.detailTextLabel.backgroundColor = [UIColor clearColor];
        self.detailTextLabel.highlightedTextColor = self.detailTextLabel.textColor;
        self.detailTextLabel.font = [UIFont systemFontOfSize:14.0f];
        self.detailTextLabel.shadowColor = [UIColor whiteColor];
        self.detailTextLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
    }
    return self;
}

#pragma mark - super implementation

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.imageView.frame = CGRectInset(self.imageView.frame, 3.0f, 3.0f);
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    self.imageView.image = nil;
}

@end
