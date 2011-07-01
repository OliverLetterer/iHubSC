//
//  GHPDefaultTableViewCell.m
//  iGithub
//
//  Created by Oliver Letterer on 24.06.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHPDefaultTableViewCell.h"
#import "GHPDefaultTableViewCellBackgroundView.h"

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
            UIImageView *imageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"UITableViewCellAccessoryDisclosureIndicatorOriginal.png"] ] autorelease];
            imageView.contentMode = UIViewContentModeCenter;
            self.accessoryView = imageView;
        }
    }
}

#pragma mark - Initialization

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        // Initialization code
        self.myBackgroundView = [[[GHPDefaultTableViewCellBackgroundView alloc] init] autorelease];
        self.backgroundView = self.myBackgroundView;
        
        self.mySelectedBackgroundView = [[[GHPDefaultTableViewCellBackgroundView alloc] init] autorelease];
        self.mySelectedBackgroundView.colors = [NSArray arrayWithObjects:
                                                (id)[UIColor colorWithRed:252.0f/255.0f green:252.0f/255.0f blue:246.0f/255.0f alpha:1.0].CGColor, 
                                                (id)[UIColor colorWithRed:241.0f/255.0f green:242.0f/255.0f blue:222.0f/255.0f alpha:1.0].CGColor,
                                                nil];
        self.selectedBackgroundView = self.mySelectedBackgroundView;
        
        self.textLabel.backgroundColor = [UIColor clearColor];
        self.textLabel.highlightedTextColor = [UIColor blackColor];
        self.textLabel.shadowColor = [UIColor whiteColor];
        self.textLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
    }
    return self;
}

#pragma mark - super implementation

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
}

#pragma mark - Memory management

- (void)dealloc {
    [_myBackgroundView release];
    [_mySelectedBackgroundView release];
    
    [super dealloc];
}

@end
