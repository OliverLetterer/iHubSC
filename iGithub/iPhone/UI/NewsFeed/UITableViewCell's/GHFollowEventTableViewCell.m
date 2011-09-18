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
        self.targetImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:self.targetImageView];
        
        self.targetNameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.targetNameLabel.font = [UIFont boldSystemFontOfSize:12.0];
        self.targetNameLabel.textColor = [UIColor colorWithWhite:0.25 alpha:1.0];
        self.targetNameLabel.highlightedTextColor = [UIColor whiteColor];
        self.targetNameLabel.backgroundColor = [UIColor clearColor];
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
    CGRect frame = self.descriptionLabel.frame;
    frame = CGRectMake(78.0f, frame.origin.y + CGRectGetHeight(frame) + 2.0f, 38.0f, 38.0f);
    self.targetImageView.frame = frame;
    self.targetNameLabel.frame = CGRectMake(124.0, frame.origin.y, 176.0, frame.size.height);
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.targetImageView.image = nil;
    self.targetNameLabel.text = nil;
}

+ (CGFloat)heightWithContent:(NSString *)content {
    CGFloat minHeight = [self height];
    
    if (!content) {
        return minHeight;
    }
    CGSize newSize = [content sizeWithFont:[UIFont systemFontOfSize:13.0f] 
                         constrainedToSize:CGSizeMake(222.0f, MAXFLOAT)
                             lineBreakMode:UILineBreakModeWordWrap];
    
    CGFloat height = newSize.height < 21.0f ? 21.0f : newSize.height;
    height += 65.0f;
    
    return height < minHeight ? minHeight : height;
}


@end
