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

@synthesize textField=_textField;

#pragma mark - Initialization

- (NSString *)submitButtonText {
    return NSLocalizedString(@"Done", @"");
}

- (void)toolbarDoneButtonClicked:(UIBarButtonItem *)barButton {
    [self.textView resignFirstResponder];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        // Initialization code
        self.textField = [[UITextField alloc] initWithFrame:CGRectZero];
        self.textField.borderStyle = UITextBorderStyleLine;
        self.textField.placeholder = NSLocalizedString(@"Title", @"");
        self.textField.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:self.textField];
    }
    return self;
}

#pragma mark - super implementation

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.textField.frame = CGRectMake(10.0f, 10.0f, CGRectGetWidth(self.contentView.bounds)-20.0f, 26.0f);
    self.textView.frame = CGRectMake(10.0f, 46.0f, CGRectGetWidth(self.contentView.bounds)-20.0f, CGRectGetHeight(self.contentView.bounds)-56.0f);
}

@end
