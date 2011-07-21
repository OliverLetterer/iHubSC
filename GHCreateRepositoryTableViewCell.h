//
//  MyTableViewCell.h
//  Installous
//
//  Created by Oliver Letterer on 25.03.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GHTableViewCell.h"

@interface GHCreateRepositoryTableViewCell : GHTableViewCell {
@private
    UILabel *_publicLabel;
    UISwitch *_publicSwitch;
    UITextField *_titleTextField;
    UITextField *_descriptionTextField;
}

@property (nonatomic, retain) UILabel *publicLabel;
@property (nonatomic, retain) UISwitch *publicSwitch;
@property (nonatomic, retain) UITextField *titleTextField;
@property (nonatomic, retain) UITextField *descriptionTextField;

@end
