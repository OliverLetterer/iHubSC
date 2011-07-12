//
//  ANNotificationViewBackgroundView.h
//  iGithub
//
//  Created by Oliver Letterer on 12.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ANNotificationViewBackgroundView : UIView {
@private
    NSArray *_colors;
    CGGradientRef _gradient;
    CGColorSpaceRef _colorSpace;
}

@property (nonatomic, retain) NSArray *colors;

@end
