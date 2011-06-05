//
//  GHTableViewController.h
//  iGithub
//
//  Created by Oliver Letterer on 06.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UITableView+Additions.h"
#import "GHAuthenticationViewController.h"
#import "UIExpandableTableView.h"
#import "UIViewController+GHErrorHandling.h"
#import "GHTableViewControllerAlertViewProxy.h"
#import "GHPullToReleaseTableViewController.h"

@class GHNewsFeedItemTableViewCell;

@interface GHTableViewController : GHPullToReleaseTableViewController <GHAuthenticationViewControllerDelegate, UIExpandableTableViewDatasource, UIExpandableTableViewDelegate> {
@private
    NSMutableDictionary *_cachedHeightsDictionary;
    BOOL _reloadDataIfNewUserGotAuthenticated;
    BOOL _reloadDataOnApplicationWillEnterForeground;
    
    GHTableViewControllerAlertViewProxy *_alertProxy;
    
    BOOL _hasGradientBackgrounds;
}

@property (nonatomic, retain) UIExpandableTableView *tableView;

@property (nonatomic, retain) NSMutableDictionary *cachedHeightsDictionary;
@property (nonatomic, readonly) UITableViewCell *dummyCell;

@property (nonatomic, assign) BOOL reloadDataIfNewUserGotAuthenticated;
@property (nonatomic, assign) BOOL reloadDataOnApplicationWillEnterForeground;  // default: YES

- (UITableViewCell *)dummyCellWithText:(NSString *)text;
- (CGFloat)heightForDescription:(NSString *)description;

- (void)updateImageViewForCell:(GHNewsFeedItemTableViewCell *)cell 
                   atIndexPath:(NSIndexPath *)indexPath 
                withGravatarID:(NSString *)gravatarID;

- (void)authenticationViewControllerdidAuthenticateUserCallback:(NSNotification *)notification;
- (void)applicationWillEnterForegroundCallback:(NSNotification *)notification;

@end




@interface GHTableViewController (GHHeightCaching)

- (void)cacheHeight:(CGFloat)height forRowAtIndexPath:(NSIndexPath *)indexPath;
- (CGFloat)cachedHeightForRowAtIndexPath:(NSIndexPath *)indexPath;
- (BOOL)isHeightCachedForRowAtIndexPath:(NSIndexPath *)indexPath;

@end
