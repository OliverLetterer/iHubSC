//
//  GHTextFieldTableViewCell.m
//  iGithub
//
//  Created by Oliver Letterer on 02.08.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHTextFieldTableViewCell.h"


@implementation GHTextFieldTableViewCell
@synthesize textField=_textField;

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Initialization

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        _textField = [[UITextField alloc] init];
        _textField.font = [UIFont boldSystemFontOfSize:17.0f];
        _textField.placeholder = NSLocalizedString(@"Title", @"");
        _textField.borderStyle = UITextBorderStyleBezel;
        _textField.backgroundColor = [UIColor whiteColor];
        _textField.delegate = self;
        [self.contentView addSubview:_textField];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.accessoryType = UITableViewCellAccessoryNone;
    }
    return self;
}

#pragma mark - super implementation

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _textField.frame = CGRectInset(self.contentView.bounds, 3.0f, 3.0f);
}

@end
