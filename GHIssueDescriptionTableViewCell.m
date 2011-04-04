//
//  GHIssueDescriptionTableViewCell.m
//  iGithub
//
//  Created by Oliver Letterer on 04.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHIssueDescriptionTableViewCell.h"


@implementation GHIssueDescriptionTableViewCell

#pragma mark - Initialization

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        // Initialization code
        self.textLabel.font = [UIFont systemFontOfSize:16.0];
        self.textLabel.lineBreakMode = UILineBreakModeWordWrap;
        self.textLabel.numberOfLines = 0;
        self.textLabel.adjustsFontSizeToFitWidth = NO;
        
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
    
    self.textLabel.frame = CGRectMake(10.0, 5.0, self.contentView.bounds.size.width - 20.0, self.contentView.bounds.size.height - 10.0);
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
}

#pragma mark - Memory management

- (void)dealloc {
    [_myContentView release];
    [super dealloc];
}

@end
