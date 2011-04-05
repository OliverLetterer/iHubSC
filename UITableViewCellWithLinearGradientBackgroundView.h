//
//  UITableViewCellWithLinearGradientBackgroundView.h
//  iGithub
//
//  Created by Oliver Letterer on 05.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface UITableViewCellWithLinearGradientBackgroundView : UITableViewCell {
@private
    CAGradientLayer *_backgroundGradientLayer;
}

@property (nonatomic, retain) CAGradientLayer *backgroundGradientLayer;

@end
