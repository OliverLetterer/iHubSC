//
//  MyTableViewCell.h
//  Installous
//
//  Created by Oliver Letterer on 25.03.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GHPNewCommentTableViewCell.h"

@interface GHPCreateIssueTitleAndDescriptionTableViewCell : GHPNewCommentTableViewCell {
@private
    UITextField *_textField;
}

@property (nonatomic, retain) UITextField *textField;

@end
