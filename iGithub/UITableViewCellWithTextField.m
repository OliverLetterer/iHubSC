//
//  UITableViewCellWithTextField.m
//  Installous
//
//  Created by oliver on 29.06.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "UITableViewCellWithTextField.h"


@implementation UITableViewCellWithTextField

@synthesize textField=_textField, delegate=_delegate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        // Initialization code
		self.textField = [[[UITextField alloc] initWithFrame:CGRectMake(125, 10, 175, 25)] autorelease];
		self.textField.textAlignment = UITextAlignmentRight;
		self.textField.returnKeyType = UIReturnKeyDone;
		self.textField.font = [UIFont systemFontOfSize:14.0];
		self.textField.delegate = self;
		self.selectionStyle = UITableViewCellSelectionStyleNone;
		[self addSubview:self.textField];
    }
    return self;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[self.textField resignFirstResponder];
	[self.delegate cellWithTextFieldDidEnterText:self];
	return YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)dealloc {
	self.textField = nil;
    [super dealloc];
}


@end
