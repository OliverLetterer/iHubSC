//
//  GHNewCommentTableViewCell.m
//  iGithub
//
//  Created by Oliver Letterer on 05.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHNewCommentTableViewCell.h"
#import <QuartzCore/QuartzCore.h>

#define kUIActionSheetTagFormat             172635
#define kUIActionSheetTagInsert             172636

#define kUIAlertViewTagLinkText             12984
#define kUIAlertViewTagLinkURL              12985

CGFloat const GHNewCommentTableViewCellHeight = 161.0f;

@implementation GHNewCommentTableViewCell
@synthesize textView=_textView;
@synthesize linkText=_linkText, linkURL=_linkURL;
@synthesize delegate=_delegate;

#pragma mark - Setters and getters

- (UIView *)textViewInputAccessoryView {
    UIToolbar *toolbar = [[[UIToolbar alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 44.0)] autorelease];
    toolbar.barStyle = UIBarStyleBlackTranslucent;
    
    UIBarButtonItem *item = nil;
    NSMutableArray *items = [NSMutableArray array];
    
    item = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Format", @"") 
                                             style:UIBarButtonItemStyleBordered 
                                            target:self 
                                            action:@selector(toolbarFormatButtonClicked:)]
            autorelease];
    [items addObject:item];
    
    item = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Insert", @"") 
                                             style:UIBarButtonItemStyleBordered 
                                            target:self 
                                            action:@selector(toolbarInsertButtonClicked:)]
            autorelease];
    [items addObject:item];
    
    item = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", @"") 
                                             style:UIBarButtonItemStyleBordered 
                                            target:self 
                                            action:@selector(toolbarCancelButtonClicked:)]
            autorelease];
    [items addObject:item];
    
    item = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace 
                                                          target:nil 
                                                          action:@selector(noAction)]
            autorelease];
    [items addObject:item];
    
    item = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Submit", @"") 
                                             style:UIBarButtonItemStyleDone 
                                            target:self 
                                            action:@selector(toolbarDoneButtonClicked:)]
            autorelease];
    [items addObject:item];
    
    toolbar.items = items;
    
    return toolbar;
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == kUIActionSheetTagFormat) {
        NSString *title = nil;
        @try {
            title = [actionSheet buttonTitleAtIndex:buttonIndex];
        }
        @catch (NSException *exception) {
        }
        
        UITextRange *range = self.textView.selectedTextRange;
        NSString *text = [self.textView textInRange:self.textView.selectedTextRange];
        
        if ([title isEqualToString:NSLocalizedString(@"*emphasized*", @"")]) {
            [self.textView replaceRange:range withText:[NSString stringWithFormat:@"*%@*", text] ];
        } else if ([title isEqualToString:NSLocalizedString(@"**strong emphasized**", @"")]) {
            [self.textView replaceRange:range withText:[NSString stringWithFormat:@"**%@**", text] ];
        } else if ([title isEqualToString:NSLocalizedString(@"First Level Header", @"")]) {
            [self.textView replaceRange:range withText:[NSString stringWithFormat:@"%@\n====================", text] ];
        } else if ([title isEqualToString:NSLocalizedString(@"Second Level Header", @"")]) {
            [self.textView replaceRange:range withText:[NSString stringWithFormat:@"%@\n---------------------", text] ];
        } else if ([title isEqualToString:NSLocalizedString(@"Third Level Header", @"")]) {
            [self.textView replaceRange:range withText:[NSString stringWithFormat:@"###%@", text] ];
        }
    } else if (actionSheet.tag == kUIActionSheetTagInsert) {
        NSString *title = nil;
        @try {
            title = [actionSheet buttonTitleAtIndex:buttonIndex];
        }
        @catch (NSException *exception) {
        }
        
        if ([title isEqualToString:NSLocalizedString(@"Hyperlink", @"")]) {
            UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Input Text", @"") 
                                                             message:NSLocalizedString(@"", @"") 
                                                            delegate:self 
                                                   cancelButtonTitle:NSLocalizedString(@"Cancel", @"") 
                                                   otherButtonTitles:NSLocalizedString(@"Next", @""), nil]
                                  autorelease];
            alert.alertViewStyle = UIAlertViewStylePlainTextInput;
            alert.tag = kUIAlertViewTagLinkText;
            [alert show];
        }
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == kUIAlertViewTagLinkText) {
        if (buttonIndex > 0) {
            self.linkText = [alertView textFieldAtIndex:0].text;
            UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Input URL", @"") 
                                                             message:NSLocalizedString(@"", @"") 
                                                            delegate:self 
                                                   cancelButtonTitle:NSLocalizedString(@"Cancel", @"") 
                                                   otherButtonTitles:NSLocalizedString(@"Done", @""), nil]
                                  autorelease];
            alert.alertViewStyle = UIAlertViewStylePlainTextInput;
            alert.tag = kUIAlertViewTagLinkURL;
            [alert show];
        }
    } else if (alertView.tag == kUIAlertViewTagLinkURL) {
        if (buttonIndex > 0) {
            self.linkURL = [alertView textFieldAtIndex:0].text;
            
            UITextRange *range = self.textView.selectedTextRange;
            [self.textView replaceRange:range withText:[NSString stringWithFormat:@"[%@](%@)", self.linkText, self.linkURL] ];
        }
    }
}

#pragma mark - Target actions

- (void)toolbarCancelButtonClicked:(UIBarButtonItem *)barButton {
    [self.textView resignFirstResponder];
}

- (void)toolbarDoneButtonClicked:(UIBarButtonItem *)barButton {
    [self.delegate newCommentTableViewCell:self didEnterText:self.textView.text];
}

- (void)toolbarInsertButtonClicked:(UIBarButtonItem *)barButton {
    UIActionSheet *sheet = [[[UIActionSheet alloc] init] autorelease];
    
    sheet.title = NSLocalizedString(@"Insert", @"");
    [sheet addButtonWithTitle:NSLocalizedString(@"Hyperlink", @"")];
    [sheet addButtonWithTitle:NSLocalizedString(@"Cancel", @"")];
    sheet.cancelButtonIndex = 1;
    sheet.delegate = self;
    sheet.tag = kUIActionSheetTagInsert;
    sheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    
    [sheet showInView:[UIApplication sharedApplication].delegate.window.rootViewController.view];
}

- (void)toolbarFormatButtonClicked:(UIBarButtonItem *)barButton {
    UIActionSheet *sheet = [[[UIActionSheet alloc] init] autorelease];
    
    sheet.title = NSLocalizedString(@"Select Format", @"");
    [sheet addButtonWithTitle:NSLocalizedString(@"*emphasized*", @"")];
    [sheet addButtonWithTitle:NSLocalizedString(@"**strong emphasized**", @"")];
    [sheet addButtonWithTitle:NSLocalizedString(@"First Level Header", @"")];
    [sheet addButtonWithTitle:NSLocalizedString(@"Second Level Header", @"")];
    [sheet addButtonWithTitle:NSLocalizedString(@"Third Level Header", @"")];
    [sheet addButtonWithTitle:NSLocalizedString(@"Cancel", @"")];
    sheet.cancelButtonIndex = 5;
    sheet.delegate = self;
    sheet.tag = kUIActionSheetTagFormat;
    sheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    
    [sheet showInView:[UIApplication sharedApplication].delegate.window.rootViewController.view];
}

#pragma mark - UITextViewDelegate

- (void)textViewDidChangeSelection:(UITextView *)textView {
    UIToolbar *toolbar = (UIToolbar *)textView.inputAccessoryView;
    UIBarButtonItem *item = [toolbar.items objectAtIndex:0];
    item.enabled = textView.selectedRange.length > 0;
}

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
        
        self.accessoryType = UITableViewCellAccessoryNone;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.textView.inputAccessoryView = self.textViewInputAccessoryView;
        self.textView.scrollsToTop = NO;
        self.textView.delegate = self;
        
        [self.contentView addSubview:self.textView];
    }
    return self;
}

#pragma mark - super implementation

- (void)layoutSubviews {
    [super layoutSubviews];
    self.textView.frame = CGRectMake(78.0, 26.0, 222.0, 128.0);
}

#pragma mark - Memory management

- (void)dealloc {
    [_textView release];
    [_linkText release];
    [_linkURL release];
    
    [super dealloc];
}

@end
