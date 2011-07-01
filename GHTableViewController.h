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
#import "GHPDefaultTableViewCell.h"
#import "GHAuthenticationManager.h"
#import "GithubAPI.h"
#import "INNotificationQueue.h"
#import "ANAdvancedNavigationController.h"

@class GHNewsFeedItemTableViewCell;

@interface GHTableViewController : GHPullToReleaseTableViewController <GHAuthenticationViewControllerDelegate, UIExpandableTableViewDatasource, UIExpandableTableViewDelegate> {
@private
    NSMutableDictionary *_nextPageForSectionsDictionary;
    NSMutableDictionary *_cachedHeightsDictionary;
    BOOL _reloadDataIfNewUserGotAuthenticated;
    BOOL _reloadDataOnApplicationWillEnterForeground;
    
    GHTableViewControllerAlertViewProxy *_alertProxy;
    
    BOOL _hasGradientBackgrounds;
    
    UITableViewStyle _myTableViewStyle;
}

@property (nonatomic, retain) UIExpandableTableView *tableView;

@property (nonatomic, retain) NSMutableDictionary *nextPageForSectionsDictionary;
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

- (id)keyForSection:(NSUInteger)section;
- (void)setNextPage:(NSUInteger)nextPage forSection:(NSUInteger)section;
- (BOOL)needsToDownloadNextDataInSection:(NSUInteger)section;
- (NSUInteger)nextPageForSection:(NSUInteger)section;

- (void)downloadDataForPage:(NSUInteger)page inSection:(NSUInteger)section;

@end



@interface GHTableViewController (iPad)

- (void)setupDefaultTableViewCell:(GHPDefaultTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath;
- (GHPDefaultTableViewCell *)defaultTableViewCellForRowAtIndexPath:(NSIndexPath *)indexPath withReuseIdentifier:(NSString *)CellIdentifier;

@end



@interface GHTableViewController (GHHeightCaching)

- (void)cacheHeight:(CGFloat)height forRowAtIndexPath:(NSIndexPath *)indexPath;
- (CGFloat)cachedHeightForRowAtIndexPath:(NSIndexPath *)indexPath;
- (BOOL)isHeightCachedForRowAtIndexPath:(NSIndexPath *)indexPath;

@end
