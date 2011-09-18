//
//  GHPNewsFeedSecondUserTableViewCell.m
//  iGithub
//
//  Created by Oliver Letterer on 11.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHPNewsFeedSecondUserTableViewCell.h"


@implementation GHPNewsFeedSecondUserTableViewCell

@synthesize secondImageView=_secondImageView, secondLabel=_secondLabel;

#pragma mark - Initialization

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        // Initialization code
        self.secondImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:self.secondImageView];
        
        _secondLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _secondLabel.backgroundColor = self.detailTextLabel.backgroundColor;
        _secondLabel.highlightedTextColor = self.detailTextLabel.highlightedTextColor;
        _secondLabel.font = self.detailTextLabel.font;
        _secondLabel.shadowColor = self.detailTextLabel.shadowColor;
        _secondLabel.shadowOffset = self.detailTextLabel.shadowOffset;
        _secondLabel.textColor = self.detailTextLabel.textColor;
        [self.contentView addSubview:_secondLabel];
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
    
    self.secondImageView.frame = CGRectMake(self.textLabel.frame.origin.x, self.detailTextLabel.frame.origin.y + CGRectGetHeight(self.detailTextLabel.frame) + 2.0f, 36.0, 36.0);
    CGRect frame = self.secondImageView.frame;
    frame.origin.x += CGRectGetWidth(frame)+8.0f;
    frame.size.width = CGRectGetWidth(self.contentView.bounds)-frame.origin.x;
    _secondLabel.frame = frame;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
}

+ (CGFloat)heightWithContent:(NSString *)content {
    if (!content) {
        return GHPDefaultNewsFeedTableViewCellHeight;
    }
    
    CGSize size = [content sizeWithFont:[UIFont systemFontOfSize:14.0f]
                      constrainedToSize:CGSizeMake(317.0f, CGFLOAT_MAX) 
                          lineBreakMode:UILineBreakModeWordWrap];
    
    CGFloat height = size.height + 79.0f;
    if (height < GHPDefaultNewsFeedTableViewCellHeight) {
        height = GHPDefaultNewsFeedTableViewCellHeight;
    }
    
    return height;
}

@end
