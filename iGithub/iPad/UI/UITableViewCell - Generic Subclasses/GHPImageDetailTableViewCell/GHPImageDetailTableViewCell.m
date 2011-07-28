//
//  GHPImageDetailTableViewCell.m
//  iGithub
//
//  Created by Oliver Letterer on 02.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHPImageDetailTableViewCell.h"


@implementation GHPImageDetailTableViewCell

#pragma mark - Initialization

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        self.detailTextLabel.numberOfLines = 0;
        self.detailTextLabel.lineBreakMode = UILineBreakModeWordWrap;
        
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
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
    
    self.imageView.frame = CGRectMake(10.0f, 10.0f, 56.0f, 56.0f);
    self.textLabel.frame = CGRectMake(76.0f, 10.0f, CGRectGetWidth(self.contentView.bounds) - 76.0f, 21.0f);
    self.detailTextLabel.frame = CGRectMake(76.0f, 31.0f, CGRectGetWidth(self.contentView.bounds) - 76.0f, 10.0f);
    [self.detailTextLabel sizeToFit];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
}

+ (CGFloat)heightWithContent:(NSString *)content {
    CGSize size = [content sizeWithFont:[UIFont systemFontOfSize:14.0f]
                      constrainedToSize:CGSizeMake(317.0f, CGFLOAT_MAX) 
                          lineBreakMode:UILineBreakModeWordWrap];
    
    CGFloat height = size.height + 41.0f;
    if (height < 80.0f) {
        height = 80.0f;
    }
    
    return height;
}

#pragma mark - Memory management


@end
