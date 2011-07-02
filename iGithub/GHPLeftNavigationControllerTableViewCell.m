//
//  GHPLeftNavigationControllerTableViewCell.m
//  iGithub
//
//  Created by Oliver Letterer on 30.06.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHPLeftNavigationControllerTableViewCell.h"
#import "UIImage+GHTabBar.h"
#import "GHPEdgedLineView.h"
#import "ANAdvancedNavigationController.h"

@implementation GHPLeftNavigationControllerTableViewCell

@synthesize lineView=_lineView;

#pragma mark - setters and getters

- (void)setItemImage:(UIImage *)itemImage {
    self.imageView.image = [itemImage tabBarStyledImageWithSize:itemImage.size style:NO];
    
    self.imageView.highlightedImage = [itemImage tabBarStyledImageWithSize:itemImage.size style:YES];
}

#pragma mark - Initialization

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        // Initialization code
        self.textLabel.textColor = [UIColor colorWithWhite:0.55f alpha:1.0f];
        self.textLabel.shadowColor = [UIColor blackColor];
        UIView *selectedBackgroundView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
        selectedBackgroundView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.25f];
        self.selectedBackgroundView = selectedBackgroundView;
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        
        self.backgroundView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
        self.backgroundView.backgroundColor = [UIColor clearColor];
        self.lineView = [[[GHPEdgedLineView alloc] initWithFrame:CGRectZero] autorelease];
        self.lineView.transform = CGAffineTransformMakeRotation(M_PI / 2.0f);
        [self.backgroundView addSubview:self.lineView];
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
    
    self.lineView.frame = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.backgroundView.bounds), 2.0f);
    self.imageView.center = CGPointMake(ANAdvancedNavigationControllerDefaultLeftPanningOffset/2.0f, CGRectGetHeight(self.contentView.bounds) / 2.0f);
    self.textLabel.frame = CGRectMake(ANAdvancedNavigationControllerDefaultLeftPanningOffset, 0.0f, CGRectGetWidth(self.contentView.bounds) - ANAdvancedNavigationControllerDefaultLeftPanningOffset, CGRectGetHeight(self.contentView.bounds));
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
}

#pragma mark - Memory management

- (void)dealloc {
    [_lineView release];
    [super dealloc];
}

@end
