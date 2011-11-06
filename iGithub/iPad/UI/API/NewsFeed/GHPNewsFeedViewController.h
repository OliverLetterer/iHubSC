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
@protected
    NSMutableArray *_events;
}

@property (nonatomic, strong) NSMutableArray *events;

- (UITableViewCell *)tableView:(UITableView *)tableView 
                  cellForEvent:(GHAPIEventV3 *)event 
                   atIndexPath:(NSIndexPath *)indexPath;

- (void)tableView:(UITableView *)tableView 
   didSelectEvent:(GHAPIEventV3 *)event 
      atIndexPath:(NSIndexPath *)indexPath;

- (void)cacheHeightForTableView;

- (NSString *)descriptionForEvent:(GHAPIEventV3 *)event;
- (void)downloadNewsFeed;

@end
