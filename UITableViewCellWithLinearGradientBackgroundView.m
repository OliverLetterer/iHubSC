//
//  UITableViewCellWithLinearGradientBackgroundView.m
//  iGithub
//
//  Created by Oliver Letterer on 05.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "UITableViewCellWithLinearGradientBackgroundView.h"
#import "UITableViewCell+Background.h"

@implementation UITableViewCellWithLinearGradientBackgroundView

@synthesize backgroundGradientLayer=_backgroundGradientLayer;

#pragma mark - Initialization

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        // Initialization code
        self.backgroundGradientLayer = [CAGradientLayer layer];
        self.backgroundGradientLayer.colors = [NSArray arrayWithObjects:
                                               (id)[UIColor whiteColor].CGColor, 
                                               (id)[UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0].CGColor,
                                               nil];
        self.backgroundGradientLayer.locations = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.0], [NSNumber numberWithFloat:1.0], nil];
        self.backgroundView = [[[UIView alloc] init] autorelease];
        self.backgroundView.backgroundColor = [UIColor whiteColor];
        [self.backgroundView.layer addSublayer:self.backgroundGradientLayer];
        
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
    
    self.backgroundGradientLayer.frame = self.backgroundView.bounds;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
}

#pragma mark - Memory management

- (void)dealloc {
    [_backgroundGradientLayer release];
    [super dealloc];
}

@end
