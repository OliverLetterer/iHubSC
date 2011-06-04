//
//  GHAPIMilestoneV3TableViewCell.h
//  iGithub
//
//  Created by Oliver Letterer on 30.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "INProgressView.h"
#import "UITableViewCellWithLinearGradientBackgroundView.h"

#define GHAPIMilestoneV3TableViewCellHeight 44.0f;

@interface GHAPIMilestoneV3TableViewCell : UITableViewCellWithLinearGradientBackgroundView {
@private
    INProgressView *_progressView;
}

@property (nonatomic, retain) INProgressView *progressView;

@end
