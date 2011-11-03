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
    NSArray *_events;
}

@property (nonatomic, strong) NSArray *events;

- (void)tableView:(UITableView *)tableView 
   didSelectEvent:(GHAPIEventV3 *)event 
      atIndexPath:(NSIndexPath *)indexPath;

- (void)cacheHeightForTableView;

- (NSString *)descriptionForEvent:(GHAPIEventV3 *)event;

@end
