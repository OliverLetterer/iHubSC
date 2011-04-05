//
//  UITableViewController+Additions.m
//  iGithub
//
//  Created by Oliver Letterer on 05.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "UITableViewController+Additions.h"
#import "UIImage+Gravatar.h"

@implementation UITableViewController (GHDownloadGravatarImage)

- (void)updateImageViewForCell:(GHNewsFeedItemTableViewCell *)cell 
                   atIndexPath:(NSIndexPath *)indexPath 
                withGravatarID:(NSString *)gravatarID {
    
    UIImage *gravatarImage = [UIImage cachedImageFromGravatarID:gravatarID];
    
    if (gravatarImage) {
        cell.imageView.image = gravatarImage;
        [cell.activityIndicatorView stopAnimating];
    } else {
        [cell.activityIndicatorView startAnimating];
        
        [UIImage imageFromGravatarID:gravatarID 
               withCompletionHandler:^(UIImage *image, NSError *error, BOOL didDownload) {
                   [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] 
                                         withRowAnimation:UITableViewRowAnimationNone];
               }];
    }
    
}

@end
