//
//  GHPMileStoneTableViewCell.m
//  iGithub
//
//  Created by Oliver Letterer on 05.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHPMileStoneTableViewCell.h"

CGFloat const GHPMileStoneTableViewCellHeight = 66.0f;

@implementation GHPMileStoneTableViewCell

@synthesize progressView=_progressView;

#pragma mark - Initialization

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        // Initialization code
        self.progressView = [[GHPieChartProgressView alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:self.progressView];
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
    self.progressView.frame = CGRectMake(10.0f, 5.0f, 56.0f, 56.0f);
    self.textLabel.frame = CGRectMake(74.0f, 8.0f, CGRectGetWidth(self.contentView.bounds) - 69.0f, 21.0f);
    self.detailTextLabel.frame = CGRectMake(74.0f, 37.0f, CGRectGetWidth(self.contentView.bounds) - 69.0f, 21.0f);
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
}

#pragma mark - Memory management


@end
