//
//  UITableViewCellWithLinearGradientBackgroundView.m
//  iGithub
//
//  Created by Oliver Letterer on 05.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "UITableViewCellWithLinearGradientBackgroundView.h"
#import "UITableViewCell+Background.h"
#import "GHLinearGradientBackgroundView.h"

@implementation UITableViewCellWithLinearGradientBackgroundView

@synthesize linearBackgroundView=_linearBackgroundView;

#pragma mark - Initialization

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        // Initialization code
        
        GHLinearGradientBackgroundView *backgroundView = [[[GHLinearGradientBackgroundView alloc] initWithFrame:self.bounds] autorelease];
        backgroundView.colors = [NSArray arrayWithObjects:
                                 (id)[UIColor colorWithRed:240.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:1.0].CGColor, 
                                 (id)[UIColor colorWithRed:192.0/255.0 green:192.0/255.0 blue:192.0/255.0 alpha:1.0].CGColor,
                                 nil];
        self.backgroundView = backgroundView;
        _linearBackgroundView = [backgroundView retain];
        
        self.textLabel.backgroundColor = [UIColor clearColor];
        self.detailTextLabel.backgroundColor = [UIColor clearColor];
    }
    return self;
}

#pragma mark - super implementation

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    [self setBackgroundShadowHeight:5.0];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    [self setBackgroundShadowHeight:5.0];
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
}

#pragma mark - Memory management

- (void)dealloc {
    [_linearBackgroundView release];
    [super dealloc];
}

@end
