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
@private
    GHNewsFeed *_newsFeed;
}

@property (nonatomic, retain) GHNewsFeed *newsFeed;

- (void)cacheHeightForTableView;

@end
