//
//  GHNewEventsTableViewCell.m
//  iGithub
//
//  Created by Oliver Letterer on 05.11.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHNewEventsTableViewCell.h"



@implementation GHNewEventsTableViewCell

#pragma mark - Initialization

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier 
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        // Initialization code
        self.textLabel.font = [UIFont boldSystemFontOfSize:13.0f];
        self.textLabel.textColor = [UIColor colorWithWhite:0.25f alpha:1.0f];
        self.textLabel.highlightedTextColor = [UIColor whiteColor];
        self.textLabel.backgroundColor = [UIColor clearColor];
        self.textLabel.textAlignment = UITextAlignmentCenter;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

#pragma mark - super implementation

- (void)setSelected:(BOOL)selected animated:(BOOL)animated 
{
    [super setSelected:selected animated:animated];

}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated 
{
    [super setHighlighted:highlighted animated:animated];
    
}

- (void)layoutSubviews 
{
    [super layoutSubviews];
    
}

- (void)prepareForReuse 
{
    [super prepareForReuse];
    
}

@end
