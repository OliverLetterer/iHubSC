//
//  GHLabelTableViewCell.m
//  iGithub
//
//  Created by Oliver Letterer on 22.05.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHLabelTableViewCell.h"


@implementation GHLabelTableViewCell

@synthesize colorView=_colorView;

#pragma mark - Initialization

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        // Initialization code
        self.colorView = [[UIView alloc] initWithFrame:CGRectZero];
        self.colorView.layer.masksToBounds = YES;
        self.colorView.layer.cornerRadius = 3.0f;
        [self.contentView addSubview:self.colorView];
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
    
    self.colorView.frame = CGRectMake(2.0f, 5.0f, 5.0f, self.contentView.bounds.size.height - 10.0f);
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
}

#pragma mark - Memory management


@end
