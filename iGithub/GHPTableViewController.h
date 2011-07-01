//
//  GHPTableViewController.h
//  iGithub
//
//  Created by Oliver Letterer on 24.06.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GHPDefaultTableViewCellBackgroundView.h"
#import "GHPDefaultTableViewCell.h"
#import "ANAdvancedNavigationController.h"
#import "GithubAPI.h"
#import "UIViewController+GHErrorHandling.h"
#import "INNotificationQueue.h"
#import "GHPullToReleaseTableViewController.h"

@interface GHPTableViewController : GHPullToReleaseTableViewController {
@private
    
}

@property (nonatomic, readonly) UITableViewCell *dummyCell;

- (void)setupDefaultTableViewCell:(GHPDefaultTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath;

- (GHPDefaultTableViewCell *)defaultTableViewCellForRowAtIndexPath:(NSIndexPath *)indexPath withReuseIdentifier:(NSString *)CellIdentifier;

@end
