//
//  GHNewsFeedViewController.h
//  iGithub
//
//  Created by Oliver Letterer on 30.03.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GHTableViewController.h"



@interface GHNewsFeedViewController : GHTableViewController {
@protected
    NSMutableArray *_events;
    
    NSString *_lastKnownEventDateString;
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

- (void)downloadNewEventsAfterLastKnownEventDateString:(NSString *)lastKnownEventDateString; // overwrite
- (void)appendNewEvents:(NSArray *)newEvents;   // call when done

@end
