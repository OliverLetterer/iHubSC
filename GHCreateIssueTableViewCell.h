//
//  MyTableViewCell.h
//  Installous
//
//  Created by Oliver Letterer on 25.03.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GHNewsFeedItemTableViewCell.h"

@interface GHCreateIssueTableViewCell : GHNewsFeedItemTableViewCell {
@private
    UITextField *_titleTextField;
    UITextView *_descriptionTextField;
}

@property (nonatomic, retain) UITextField *titleTextField;
@property (nonatomic, retain) UITextView *descriptionTextField;

@end
