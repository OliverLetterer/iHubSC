//
//  GHOwnerNewsFeedViewController.h
//  iGithub
//
//  Created by Oliver Letterer on 12.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GHNewsFeedViewController.h"

@interface GHOwnerNewsFeedViewController : GHNewsFeedViewController {
@private
    UISegmentedControl *_segmentControl;
}

@property (nonatomic, retain) UISegmentedControl *segmentControl;

- (void)segmentControlValueChanged:(UISegmentedControl *)segmentControl;
- (void)loadDataBasedOnSegmentControl;

@end
