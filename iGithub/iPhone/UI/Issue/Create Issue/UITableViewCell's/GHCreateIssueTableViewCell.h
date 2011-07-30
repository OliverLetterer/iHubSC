//
//  MyTableViewCell.h
//  Installous
//
//  Created by Oliver Letterer on 25.03.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GHNewCommentTableViewCell.h"

@interface GHCreateIssueTableViewCell : GHNewCommentTableViewCell {
@private
    UITextField *_titleTextField;
}

@property (nonatomic, retain) UITextField *titleTextField;

@property (nonatomic, readonly) UIView *titleTextFieldInputAccessoryView;

- (void)titleTextFieldNextButtonClicked:(UIBarButtonItem *)sender;

@end
