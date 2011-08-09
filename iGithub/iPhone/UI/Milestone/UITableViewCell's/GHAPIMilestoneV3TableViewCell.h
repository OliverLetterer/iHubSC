//
//  GHAPIMilestoneV3TableViewCell.h
//  iGithub
//
//  Created by Oliver Letterer on 30.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GHGlossProgressView.h"
#import "GHTableViewCellWithLinearGradientBackgroundView.h"

extern CGFloat const kGHAPIMilestoneV3TableViewCellHeight;

@interface GHAPIMilestoneV3TableViewCell : GHTableViewCellWithLinearGradientBackgroundView {
@private
    GHGlossProgressView *_progressView;
}

@property (nonatomic, retain) GHGlossProgressView *progressView;

@end
