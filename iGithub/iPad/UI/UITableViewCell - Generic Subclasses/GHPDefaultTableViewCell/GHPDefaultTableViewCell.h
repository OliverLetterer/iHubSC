//
//  GHPDefaultTableViewCell.h
//  iGithub
//
//  Created by Oliver Letterer on 24.06.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UITableViewCell+GHHeight.h"

@class GHPDefaultTableViewCellBackgroundView;

typedef enum {
    GHPDefaultTableViewCellStyleTop = 2,
    GHPDefaultTableViewCellStyleBottom = 3,
    GHPDefaultTableViewCellStyleCenter = 1,
    GHPDefaultTableViewCellStyleTopAndBottom = 4
} GHPDefaultTableViewCellStyle;

@interface GHPDefaultTableViewCell : UITableViewCell {
@private
    GHPDefaultTableViewCellStyle _customStyle;
    GHPDefaultTableViewCellBackgroundView *_myBackgroundView;
    GHPDefaultTableViewCellBackgroundView *_mySelectedBackgroundView;
}

@property (nonatomic, assign) GHPDefaultTableViewCellStyle customStyle;
@property (nonatomic, retain) GHPDefaultTableViewCellBackgroundView *myBackgroundView;
@property (nonatomic, retain) GHPDefaultTableViewCellBackgroundView *mySelectedBackgroundView;

@end
