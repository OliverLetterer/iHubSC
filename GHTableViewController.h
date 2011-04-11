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
#import "EGORefreshTableHeaderView.h"

@class GHNewsFeedItemTableViewCell;

@interface GHTableViewController : UITableViewController <GHAuthenticationViewControllerDelegate, EGORefreshTableHeaderDelegate> {
@private
    NSMutableDictionary *_cachedHeightsDictionary;
    BOOL _reloadDataIfNewUserGotAuthenticated;
    BOOL _reloadDataOnApplicationWillEnterForeground;
    
    // pull to release
    EGORefreshTableHeaderView *_refreshHeaderView;
	
	//  Reloading var should really be your tableviews datasource
	//  Putting it here for demo purposes 
	BOOL _reloading;
    BOOL _pullToReleaseEnabled;
    
    NSDate *_lastRefreshDate;
}

@property (nonatomic, retain) NSMutableDictionary *cachedHeightsDictionary;
@property (nonatomic, readonly) UITableViewCell *dummyCell;

@property (nonatomic, assign) BOOL reloadDataIfNewUserGotAuthenticated;
@property (nonatomic, assign) BOOL reloadDataOnApplicationWillEnterForeground;  // default: YES

- (UITableViewCell *)dummyCellWithText:(NSString *)text;
- (CGFloat)heightForDescription:(NSString *)description;

- (void)handleError:(NSError *)error;

- (void)updateImageViewForCell:(GHNewsFeedItemTableViewCell *)cell 
                   atIndexPath:(NSIndexPath *)indexPath 
                withGravatarID:(NSString *)gravatarID;

- (void)authenticationViewControllerdidAuthenticateUserCallback:(NSNotification *)notification;
- (void)applicationWillEnterForegroundCallback:(NSNotification *)notification;

@property (nonatomic, assign) BOOL pullToReleaseEnabled;

@property (nonatomic, retain) NSDate *lastRefreshDate;

- (void)reloadData;
- (void)didReloadData;

@end




@interface GHTableViewController (GHHeightCaching)

- (void)cacheHeight:(CGFloat)height forRowAtIndexPath:(NSIndexPath *)indexPath;
- (CGFloat)cachedHeightForRowAtIndexPath:(NSIndexPath *)indexPath;
- (BOOL)isHeightCachedForRowAtIndexPath:(NSIndexPath *)indexPath;

@end
