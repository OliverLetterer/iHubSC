//
//  OCPromptView.h
//  TextPrompt
//
//  Created by Objective Coders LLC on 12/31/10.
//

#import <UIKit/UIKit.h>

@interface OCPromptView : UIAlertView {
	UITextField *textField;
}

@property (nonatomic, retain) UITextField *textField;

- (id)initWithPrompt:(NSString *)prompt delegate:(id)delegate cancelButtonTitle:(NSString *)cancelTitle acceptButtonTitle:(NSString *)acceptTitle;
- (NSString *)enteredText;

@end
