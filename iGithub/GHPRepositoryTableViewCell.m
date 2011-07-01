//
//  GHPRepositoryTableViewCell.m
//  iGithub
//
//  Created by Oliver Letterer on 01.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHPRepositoryTableViewCell.h"


@implementation GHPRepositoryTableViewCell

#pragma mark - Initialization

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        // Initialization code
        self.detailTextLabel.numberOfLines = 0;
        self.detailTextLabel.lineBreakMode = UILineBreakModeWordWrap;
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
    
    self.imageView.frame = CGRectMake(10.0f, 10.0f, 64.0f, 63.0f);
    self.textLabel.frame = CGRectMake(82.0f, 10.0f, CGRectGetWidth(self.contentView.bounds) - 82.0f, 21.0f);
    self.detailTextLabel.frame = CGRectMake(82.0f, 31.0f, CGRectGetWidth(self.contentView.bounds) - 82.0f, 10.0f);
    [self.detailTextLabel sizeToFit];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
}

#pragma mark - Memory management

- (void)dealloc {
    
    [super dealloc];
}

@end
