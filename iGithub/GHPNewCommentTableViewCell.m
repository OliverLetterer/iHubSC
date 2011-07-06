//
//  GHPNewCommentTableViewCell.m
//  iGithub
//
//  Created by Oliver Letterer on 05.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHPNewCommentTableViewCell.h"
#import <QuartzCore/QuartzCore.h>

CGFloat const GHPNewCommentTableViewCellHeight = 200.0f;

@implementation GHPNewCommentTableViewCell

@synthesize textView=_textView;

#pragma mark - Initialization

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        // Initialization code
        self.textView = [[[UITextView alloc] initWithFrame:CGRectZero] autorelease];
        self.textView.font = [UIFont systemFontOfSize:16.0f];
        [self.textView.layer setBackgroundColor: [[UIColor whiteColor] CGColor]];
        [self.textView.layer setBorderColor: [[UIColor blackColor] CGColor]];
        [self.textView.layer setBorderWidth: 1.0];
        [self.textView.layer setCornerRadius:8.0f];
        [self.textView.layer setMasksToBounds:YES];
        
        [self.contentView addSubview:self.textView];
    }
    return self;
}

#pragma mark - super implementation

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat leftOffset = self.textLabel.frame.origin.x;
    CGFloat topOffset = self.textLabel.frame.origin.y + CGRectGetHeight(self.textLabel.frame) + 8.0f;
    self.textView.frame = CGRectMake(leftOffset, topOffset, 
                                     CGRectGetWidth(self.contentView.bounds)-leftOffset - 10.0f, CGRectGetHeight(self.contentView.bounds)-topOffset - 10.0f);
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
}

#pragma mark - Memory management

- (void)dealloc {
    [_textView release];
    
    [super dealloc];
}

@end
