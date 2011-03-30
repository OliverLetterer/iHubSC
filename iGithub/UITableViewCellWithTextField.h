//
//  UITableViewCellWithTextField.h
//  Installous
//
//  Created by oliver on 29.06.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UITableViewCellWithTextField;

@protocol UITableViewCellWithTextFieldDelegate
- (void)cellWithTextFieldDidEnterText:(UITableViewCellWithTextField *)cell;
@end


@interface UITableViewCellWithTextField : UITableViewCell
<UITextFieldDelegate>
{
	UITextField *_textField;
	id<UITableViewCellWithTextFieldDelegate> _delegate;
}

@property (nonatomic, retain) UITextField *textField;
@property (nonatomic, assign) id<UITableViewCellWithTextFieldDelegate> delegate;

@end
