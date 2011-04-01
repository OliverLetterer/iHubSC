//
//  GHNewsFeedViewController.h
//  iGithub
//
//  Created by Oliver Letterer on 30.03.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface GHNewsFeedViewController : UITableViewController {
    UISegmentedControl *_segmentControl;
}

@property (nonatomic, retain) UISegmentedControl *segmentControl;

@end
