//
//  GHPDefaultTableViewCell.h
//  iGithub
//
//  Created by Oliver Letterer on 24.06.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GHPDefaultTableViewCellBackgroundView;

typedef enum {
    GHPDefaultTableViewCellStyleTop = 0,
    GHPDefaultTableViewCellStyleBottom = 1,
    GHPDefaultTableViewCellStyleCenter = 2,
    GHPDefaultTableViewCellStyleTopAndBottom = 3
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
