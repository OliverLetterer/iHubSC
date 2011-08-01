//
//  MyTableViewCell.h
//  Installous
//
//  Created by Oliver Letterer on 25.03.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GHPDefaultTableViewCell.h"

@interface GHPCreateIssueTitleAndDescriptionTableViewCell : GHPDefaultTableViewCell {
@private
    UITextField *_textField;
    UITextView *_textView;
}

@property (nonatomic, retain) UITextField *textField;
@property (nonatomic, retain) UITextView *textView;

@end
