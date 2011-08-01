//
//  GHPDefaultTableViewCellBackgroundView.h
//  iGithub
//
//  Created by Oliver Letterer on 24.06.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GHPDefaultTableViewCell.h"

@interface GHPDefaultTableViewCellBackgroundView : UIView {
@private
    GHPDefaultTableViewCellStyle _customStyle;
    UIBezierPath *_borderPath;
    
    NSArray *_colors;
    CGGradientRef _gradient;
    CGColorSpaceRef _colorSpace;
}

@property (nonatomic, assign) GHPDefaultTableViewCellStyle customStyle;
@property (nonatomic, retain) UIBezierPath *borderPath;

@property (nonatomic, retain) NSArray *colors;

- (void)rebuildBorderPath;

@end
