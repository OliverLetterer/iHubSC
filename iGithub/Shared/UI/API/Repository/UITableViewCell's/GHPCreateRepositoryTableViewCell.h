//
//  GHPCreateRepositoryTableViewCell.h
//  iGithub
//
//  Created by Oliver Letterer on 04.08.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GHPDefaultTableViewCell.h"

@interface GHPCreateRepositoryTableViewCell : GHPDefaultTableViewCell {
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
