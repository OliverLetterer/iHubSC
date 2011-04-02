//
//  GHFollowEventTableViewCell.m
//  iGithub
//
//  Created by Oliver Letterer on 02.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHFollowEventTableViewCell.h"


@implementation GHFollowEventTableViewCell

@synthesize targetImageView=_targetImageView, targetNameLabel=_targetNameLabel;

#pragma mark - Initialization

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        // Initialization code
        self.targetImageView = [[[UIImageView alloc] initWithFrame:CGRectZero] autorelease];
        [self.contentView addSubview:self.targetImageView];
        
        self.targetNameLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
        self.targetNameLabel.font = [UIFont boldSystemFontOfSize:12.0];
        self.targetNameLabel.textColor = [UIColor colorWithWhite:0.25 alpha:1.0];
        self.targetNameLabel.highlightedTextColor = [UIColor whiteColor];
        [self.contentView addSubview:self.targetNameLabel];
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
    self.targetImageView.frame = CGRectMake(78.0, 26.0, 38.0, 38.0);
    self.targetNameLabel.frame = CGRectMake(124.0, 33.0, 176.0, 16.0);
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.targetImageView.image = nil;
    self.targetNameLabel.text = nil;
}

#pragma mark - Memory management

- (void)dealloc {
    [_targetImageView release];
    [_targetNameLabel release];
    [super dealloc];
}

@end
