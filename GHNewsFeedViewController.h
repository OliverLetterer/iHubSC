//
//  GHNewsFeedViewController.h
//  iGithub
//
//  Created by Oliver Letterer on 30.03.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GHTableViewController.h"

@class GHNewsFeed, GHNewsFeedItemTableViewCell, GHNewsFeedItem;

@interface GHNewsFeedViewController : GHTableViewController {
    UISegmentedControl *_segmentControl;
    GHNewsFeed *_newsFeed;
    NSDictionary *_issuesDictionary;
}

@property (nonatomic, retain) UISegmentedControl *segmentControl;
@property (nonatomic, retain) GHNewsFeed *newsFeed;

- (void)segmentControlValueChanged:(UISegmentedControl *)segmentControl;

- (void)cacheHeightForTableView;

@end
