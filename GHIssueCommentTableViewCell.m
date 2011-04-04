//
//  GHIssueCommentTableViewCell.m
//  iGithub
//
//  Created by Oliver Letterer on 04.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHIssueCommentTableViewCell.h"


@implementation GHIssueCommentTableViewCell

@synthesize timeDetailsLabel=_timeDetailsLabel;

#pragma mark - Initialization

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier])) {
        // Initialization code
        
        self.textLabel.font = [UIFont systemFontOfSize:17.0];
        self.textLabel.numberOfLines = 0;
        self.textLabel.lineBreakMode = UILineBreakModeWordWrap;
        
        self.detailTextLabel.font = [UIFont boldSystemFontOfSize:12.0];
        self.detailTextLabel.textColor = [UIColor blackColor];
        
        self.timeDetailsLabel = [[[UILabel alloc] init] autorelease];
        self.timeDetailsLabel.font = [UIFont systemFontOfSize:12.0];
        self.timeDetailsLabel.textColor = [UIColor blackColor];
        self.timeDetailsLabel.highlightedTextColor = [UIColor whiteColor];
        self.timeDetailsLabel.textAlignment = UITextAlignmentRight;
        self.timeDetailsLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.timeDetailsLabel];
        
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
    
    CGSize size = [self.textLabel.text sizeWithFont:[UIFont systemFontOfSize:17.0] 
                                  constrainedToSize:CGSizeMake(280.0, MAXFLOAT) 
                                      lineBreakMode:UILineBreakModeWordWrap];
    
    self.textLabel.frame = CGRectMake(10.0, 28.0, 280.0, size.height);
    self.detailTextLabel.frame = CGRectMake(10.0, 5.0, 280.0, 15.0);
    self.timeDetailsLabel.frame = self.detailTextLabel.frame;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
}

#pragma mark - Memory management

- (void)dealloc {
    [_timeDetailsLabel release];
    [super dealloc];
}

@end
