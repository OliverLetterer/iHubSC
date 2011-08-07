//
//  GHPTextFieldTableViewCell.h
//  iGithub
//
//  Created by Oliver Letterer on 02.08.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GHPDefaultTableViewCell.h"

@interface GHPTextFieldTableViewCell : GHPDefaultTableViewCell <UITextFieldDelegate> {
@private
    UITextField *_textField;
}

@property (nonatomic, readonly, retain) UITextField *textField;

@end
