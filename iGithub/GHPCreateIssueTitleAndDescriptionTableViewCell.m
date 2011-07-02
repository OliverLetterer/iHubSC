//
//  GHPCreateIssueTitleAndDescriptionTableViewCell.m
//  iGithub
//
//  Created by Oliver Letterer on 02.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHPCreateIssueTitleAndDescriptionTableViewCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation GHPCreateIssueTitleAndDescriptionTableViewCell

@synthesize textField=_textField, textView=_textView;

#pragma mark - Initialization

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        // Initialization code
        self.textField = [[[UITextField alloc] initWithFrame:CGRectZero] autorelease];
        self.textField.borderStyle = UITextBorderStyleLine;
        self.textField.placeholder = NSLocalizedString(@"Title", @"");
        self.textField.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:self.textField];
        
        self.textView = [[[UITextView alloc] initWithFrame:CGRectZero] autorelease];
        self.textView.font = self.textField.font;
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
    
    self.textField.frame = CGRectMake(10.0f, 10.0f, CGRectGetWidth(self.contentView.bounds)-20.0f, 26.0f);
    self.textView.frame = CGRectMake(10.0f, 46.0f, CGRectGetWidth(self.contentView.bounds)-20.0f, CGRectGetHeight(self.contentView.bounds)-56.0f);
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
}

#pragma mark - Memory management

- (void)dealloc {
    [_textField release];
    [_textView release];
    
    [super dealloc];
}

@end
