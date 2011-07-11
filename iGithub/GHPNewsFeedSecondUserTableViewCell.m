//
//  GHPNewsFeedSecondUserTableViewCell.m
//  iGithub
//
//  Created by Oliver Letterer on 11.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHPNewsFeedSecondUserTableViewCell.h"


@implementation GHPNewsFeedSecondUserTableViewCell

@synthesize secondImageView=_secondImageView;

#pragma mark - Initialization

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        // Initialization code
        self.secondImageView = [[[UIImageView alloc] initWithFrame:CGRectZero] autorelease];
        [self.contentView addSubview:self.secondImageView];
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
    
    self.secondImageView.frame = CGRectMake(self.textLabel.frame.origin.x, 30.0f, 36.0, 36.0);
    CGRect frame = self.secondImageView.frame;
    frame.origin.x += CGRectGetWidth(frame)+8.0f;
    frame.size.width = CGRectGetWidth(self.contentView.bounds)-frame.origin.x;
    self.detailTextLabel.frame = frame;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
}

#pragma mark - Memory management

- (void)dealloc {
    [_secondImageView release];
    
    [super dealloc];
}

@end
