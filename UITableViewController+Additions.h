//
//  UITableViewController+Additions.h
//  iGithub
//
//  Created by Oliver Letterer on 05.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GHNewsFeedItemTableViewCell.h"

@interface UITableViewController (GHDownloadGravatarImage)

- (void)updateImageViewForCell:(GHNewsFeedItemTableViewCell *)cell 
                   atIndexPath:(NSIndexPath *)indexPath 
                withGravatarID:(NSString *)gravatarID;

@end
