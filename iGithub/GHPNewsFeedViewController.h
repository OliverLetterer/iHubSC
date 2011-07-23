//
//  GHPNewsFeedViewController.h
//  iGithub
//
//  Created by Oliver Letterer on 10.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GHTableViewController.h"

@interface GHPNewsFeedViewController : GHTableViewController <NSCoding> {
@private
    GHNewsFeed *_newsFeed;
}

@property (nonatomic, retain) GHNewsFeed *newsFeed;

- (void)downloadNewsFeed;
- (void)cacheNewsFeedHeight;

#warning update so that only the username is in textLabel
- (NSString *)descriptionForNewsFeedItem:(GHNewsFeedItem *)item;

@end
