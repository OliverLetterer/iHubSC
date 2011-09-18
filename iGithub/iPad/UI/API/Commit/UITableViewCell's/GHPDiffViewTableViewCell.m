//
//  GHPDiffViewTableViewCell.m
//  iGithub
//
//  Created by Oliver Letterer on 03.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHPDiffViewTableViewCell.h"


@implementation GHPDiffViewTableViewCell

@synthesize diffView=_diffView;

#pragma mark - Initialization

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        // Initialization code
        self.diffView = [[GHPDiffView alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:self.diffView];
        
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
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
    self.diffView.frame = self.contentView.bounds;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
}

+ (CGFloat)heightWithContent:(NSString *)content {
    if (!content) {
        return 0.0f;
    }
    
    CGSize size = [content sizeWithFont:GHPDiffViewFont() 
                      constrainedToSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) 
                          lineBreakMode:UILineBreakModeWordWrap];
    
    return size.height;
}

#pragma mark - Memory management


@end
