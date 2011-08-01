//
//  GHPMileStoneTableViewCell.h
//  iGithub
//
//  Created by Oliver Letterer on 05.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GHPDefaultTableViewCell.h"
#import "GHPieChartProgressView.h"

extern CGFloat const GHPMileStoneTableViewCellHeight;

@interface GHPMileStoneTableViewCell : GHPDefaultTableViewCell {
@private
    GHPieChartProgressView *_progressView;
}

@property (nonatomic, retain) GHPieChartProgressView *progressView;

@end
