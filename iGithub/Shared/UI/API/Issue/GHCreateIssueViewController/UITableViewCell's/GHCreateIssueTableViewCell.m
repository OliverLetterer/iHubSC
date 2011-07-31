//
//  GHCreateIssueTableViewCell.m
//  iGithub
//
//  Created by Oliver Letterer on 14.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHCreateIssueTableViewCell.h"


@implementation GHCreateIssueTableViewCell

@synthesize titleTextField=_titleTextField;

#pragma mark - super implementation

- (void)toolbarDoneButtonClicked:(UIBarButtonItem *)barButton {
    [self.textView resignFirstResponder];
}

- (void)titleTextFieldNextButtonClicked:(UIBarButtonItem *)sender {
    [self.textView becomeFirstResponder];
}

#pragma mark - setters and getters

- (UIView *)titleTextFieldInputAccessoryView {
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 44.0)];
    toolbar.barStyle = UIBarStyleBlackTranslucent;
    
    UIBarButtonItem *item = nil;
    NSMutableArray *items = [NSMutableArray array];
    
    item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace 
                                                         target:nil 
                                                         action:@selector(noAction)];
    [items addObject:item];
    
    item = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Next", @"") 
                                            style:UIBarButtonItemStyleBordered 
                                           target:self 
                                           action:@selector(titleTextFieldNextButtonClicked:)];
    [items addObject:item];
    
    toolbar.items = items;
    
    return toolbar;
}

#pragma mark - Initialization

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        self.titleTextField = [[UITextField alloc] init];
        self.titleTextField.font = [UIFont boldSystemFontOfSize:12.0];
        self.titleTextField.placeholder = NSLocalizedString(@"Title", @"");
        self.titleTextField.borderStyle = UITextBorderStyleBezel;
        self.titleTextField.backgroundColor = [UIColor whiteColor];
        self.titleTextField.inputAccessoryView = self.titleTextFieldInputAccessoryView;
        [self.contentView addSubview:self.titleTextField];
        
        UIView *view = self.textView.inputAccessoryView;
        if ([view isKindOfClass:[UIToolbar class] ]) {
            UIToolbar *toolbar = (UIToolbar *)view;
            NSArray *items = toolbar.items;
            NSMutableArray *newItems = [NSMutableArray arrayWithCapacity:items.count];
            [items enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                UIBarButtonItem *item = obj;
                if (![item.title isEqualToString:NSLocalizedString(@"Cancel", @"")]) {
                    [newItems addObject:item];
                    
                    if ([item.title isEqualToString:NSLocalizedString(@"Submit", @"")]) {
                        item.title = NSLocalizedString(@"Done", @"");
                    }
                }
            }];
            toolbar.items = newItems;
        }
    }
    return self;
}

#pragma mark - super implementation

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.titleTextField.frame = CGRectMake(70.0f, 10.0f, CGRectGetWidth(self.contentView.bounds) - 70.0f - 10.0f, 21.0f);
    self.textView.frame = CGRectMake(70.0f, 39.0f, CGRectGetWidth(self.contentView.bounds) - 70.0f - 10.0f, CGRectGetHeight(self.contentView.bounds) - 39.0f - 10.0f);
}

@end
