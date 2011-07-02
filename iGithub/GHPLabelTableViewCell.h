//
//  GHPLabelTableViewCell.h
//  iGithub
//
//  Created by Oliver Letterer on 02.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GHPDefaultTableViewCell.h"

@interface GHPLabelTableViewCell : GHPDefaultTableViewCell {
@private
    UIView *_colorView;
}

@property (nonatomic, retain) UIView *colorView;

@end
