//
//  GHNewsFeedViewController.h
//  iGithub
//
//  Created by Oliver Letterer on 30.03.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GHNewsFeed;

@interface GHNewsFeedViewController : UITableViewController {
    UISegmentedControl *_segmentControl;
    GHNewsFeed *_newsFeed;
    NSDictionary *_issuesDictionary;
}

@property (nonatomic, retain) UISegmentedControl *segmentControl;
@property (nonatomic, retain) GHNewsFeed *newsFeed;

@end
