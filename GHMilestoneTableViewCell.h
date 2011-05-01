//
//  GHMilestoneTableViewCell.h
//  iGithub
//
//  Created by Oliver Letterer on 30.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PDColoredProgressView.h"
#import "UITableViewCellWithLinearGradientBackgroundView.h"

#define GHMilestoneTableViewCellHeight 44.0f;

@interface GHMilestoneTableViewCell : UITableViewCellWithLinearGradientBackgroundView {
@private
    PDColoredProgressView *_progressView;
}

@property (nonatomic, retain) PDColoredProgressView *progressView;

@end
