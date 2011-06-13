//
//  OCPromptView.m
//  TextPrompt
//
//  Created by Objective Coders LLC on 12/31/10.
//

#import "OCPromptView.h"

@implementation OCPromptView

@synthesize textField;

- (id)initWithPrompt:(NSString *)prompt delegate:(id)delegate cancelButtonTitle:(NSString *)cancelTitle acceptButtonTitle:(NSString *)acceptTitle {
	while ([prompt sizeWithFont:[UIFont systemFontOfSize:18.0]].width > 240.0) {
		prompt = [NSString stringWithFormat:@"%@...", [prompt substringToIndex:[prompt length] - 4]];
	}
    if ((self = [super initWithTitle:prompt message:@"\n" delegate:delegate cancelButtonTitle:cancelTitle otherButtonTitles:acceptTitle, nil])) {
        UITextField *theTextField = [[UITextField alloc] initWithFrame:CGRectMake(12.0, 45.0, 260.0, 31.0)]; 
		[theTextField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
		[theTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
		[theTextField setBorderStyle:UITextBorderStyleRoundedRect];
		[theTextField setBackgroundColor:[UIColor clearColor]];
		[theTextField setTextAlignment:UITextAlignmentLeft];
        [theTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
		
        [self addSubview:theTextField];
		
        self.textField = theTextField;
        [theTextField release];
		
		// if not >= 4.0
		NSString *sysVersion = [[UIDevice currentDevice] systemVersion];
		if (![sysVersion compare:@"4.0" options:NSNumericSearch] == NSOrderedDescending) {
			CGAffineTransform translate = CGAffineTransformMakeTranslation(0.0, 130.0); 
			[self setTransform:translate];
		}
    }
    return self;
}

- (void)show {
    [textField becomeFirstResponder];
    [super show];
}

- (NSString *)enteredText {
    return textField.text;
}

- (void)dealloc {
    [textField release];
    [super dealloc];
}

@end
