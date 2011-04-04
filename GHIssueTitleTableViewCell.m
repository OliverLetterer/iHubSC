//
//  GHIssueTitleTableViewCell.m
//  iGithub
//
//  Created by Oliver Letterer on 04.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHIssueTitleTableViewCell.h"


@implementation GHIssueTitleTableViewCell

#pragma mark - Initialization

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier])) {
        // Initialization code
        self.textLabel.font = [UIFont systemFontOfSize:17.0];
        self.textLabel.numberOfLines = 0;
        
        self.detailTextLabel.font = [UIFont systemFontOfSize:11.0];
        self.detailTextLabel.textColor = [UIColor blackColor];
        self.detailTextLabel.textAlignment = UITextAlignmentRight;
        
        self.selectionStyle = UITableViewCellEditingStyleNone;
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
    
    CGSize headerSize = [self.textLabel.text sizeWithFont:[UIFont systemFontOfSize:17.0]
                                        constrainedToSize:CGSizeMake(280.0, MAXFLOAT) 
                                            lineBreakMode:UILineBreakModeWordWrap];
    self.textLabel.frame = CGRectMake(10.0, 5.0, headerSize.width, headerSize.height);
    self.detailTextLabel.frame = CGRectMake(10.0, self.contentView.bounds.size.height - 17.0, 
                                            280.0, 15.0);
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
}

#pragma mark - Memory management

- (void)dealloc {
    [super dealloc];
}

@end
