//
//  GHLinearGradientSelectedBackgroundView.h
//  iGithub
//
//  Created by Oliver Letterer on 08.08.11.
//  Copyright (c) 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GHLinearGradientBackgroundView.h"

@interface GHLinearGradientSelectedBackgroundView : GHLinearGradientBackgroundView {
    CGGradientRef _shadowGradient;  // retained
}

@end
