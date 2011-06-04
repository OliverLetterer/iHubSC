//
//  GHNewCommentTableViewCell.m
//  iGithub
//
//  Created by Oliver Letterer on 05.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHNewCommentTableViewCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation GHNewCommentTableViewCell

@synthesize textView=_textView;

#pragma mark - Initialization

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        // Initialization code
        self.textView = [[[UITextView alloc] init] autorelease];
        self.textView.backgroundColor = [UIColor whiteColor];
        self.textView.font = [UIFont systemFontOfSize:12.0];
        self.textView.layer.borderColor = [UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0].CGColor;
        self.textView.layer.borderWidth = 1.0;
        self.selectionStyle = UITableViewCellEditingStyleNone;
        self.accessoryType = UITableViewCellAccessoryNone;
        [self.contentView addSubview:self.textView];
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
    self.textView.frame = CGRectMake(78.0, 26.0, 222.0, 128.0);
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
