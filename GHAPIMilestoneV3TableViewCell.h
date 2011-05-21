//
//  GHAPIMilestoneV3TableViewCell.h
//  iGithub
//
//  Created by Oliver Letterer on 30.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PDColoredProgressView.h"
#import "UITableViewCellWithLinearGradientBackgroundView.h"

#define GHAPIMilestoneV3TableViewCellHeight 44.0f;

@interface GHAPIMilestoneV3TableViewCell : UITableViewCellWithLinearGradientBackgroundView {
@private
    PDColoredProgressView *_progressView;
}

@property (nonatomic, retain) PDColoredProgressView *progressView;

@end
