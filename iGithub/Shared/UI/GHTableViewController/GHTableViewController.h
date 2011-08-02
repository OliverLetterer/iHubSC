//
//  GHTableViewController.h
//  iGithub
//
//  Created by Oliver Letterer on 06.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UITableView+Additions.h"
#import "UIExpandableTableView.h"
#import "UIViewController+GHErrorHandling.h"
#import "GHTableViewControllerAlertViewProxy.h"
#import "GHPullToReleaseTableViewController.h"
#import "GHPDefaultTableViewCell.h"
#import "GHAPIAuthenticationManager.h"
#import "GithubAPI.h"
#import "ANAdvancedNavigationController.h"
#import "GHPCollapsingAndSpinningTableViewCell.h"
#import "GHCollapsingAndSpinningTableViewCell.h"

@class GHTableViewCell;

@interface GHTableViewController : GHPullToReleaseTableViewController <UIExpandableTableViewDatasource, UIExpandableTableViewDelegate> {
@private
    NSMutableDictionary *_nextPageForSectionsDictionary;
    NSMutableDictionary *_cachedHeightsDictionary;
    BOOL _reloadDataIfNewUserGotAuthenticated;
    BOOL _reloadDataOnApplicationWillEnterForeground;
    
    GHTableViewControllerAlertViewProxy *_alertProxy;
    
    BOOL _hasGradientBackgrounds;
    
    UITableViewStyle _myTableViewStyle;
    
    BOOL _isDownloadingEssentialData;
    UIView *_downloadingEssentialDataView;
    
    BOOL _isInBackgroundMode;
    
    // restoring state
    CGPoint _lastContentOffset;
    NSIndexPath *_lastSelectedIndexPath;
    
    NSArray *_sectionsStateArray;
    
    BOOL _presentedInPopoverController;
}

@property (nonatomic, assign, getter = isPresentedInPopoverController) BOOL presentedInPopoverController;

@property (nonatomic, retain) NSArray *sectionsStateArray;

@property (nonatomic, copy) NSIndexPath *lastSelectedIndexPath;

@property (nonatomic, retain) UIExpandableTableView *tableView;

@property (nonatomic, retain) NSMutableDictionary *nextPageForSectionsDictionary;
@property (nonatomic, retain) NSMutableDictionary *cachedHeightsDictionary;
@property (nonatomic, readonly) UITableViewCell *dummyCell;

@property (nonatomic, assign) BOOL reloadDataIfNewUserGotAuthenticated;
@property (nonatomic, assign) BOOL reloadDataOnApplicationWillEnterForeground;  // default: YES

@property (nonatomic, assign) BOOL isDownloadingEssentialData;
@property (nonatomic, retain) UIView *downloadingEssentialDataView;
- (void)loadAndDisplayDownloadingEssentialDataView;

- (UITableViewCell *)dummyCellWithText:(NSString *)text;

- (void)updateImageView:(UIImageView *)imageView 
            inTableView:(UITableView *)tableView 
            atIndexPath:(NSIndexPath *)indexPath 
         withGravatarID:(NSString *)gravatarID;

- (void)updateImageView:(UIImageView *)imageView 
            atIndexPath:(NSIndexPath *)indexPath 
         withGravatarID:(NSString *)gravatarID;

- (void)updateImageView:(UIImageView *)imageView 
            inTableView:(UITableView *)tableView 
            atIndexPath:(NSIndexPath *)indexPath 
         withAvatarURLString:(NSString *)avatarURLString;

- (void)updateImageView:(UIImageView *)imageView 
            atIndexPath:(NSIndexPath *)indexPath 
         withAvatarURLString:(NSString *)avatarURLString;

- (void)authenticationManagerDidAuthenticateUserCallback:(NSNotification *)notification;
- (void)applicationWillEnterForegroundCallback:(NSNotification *)notification;
- (void)applicationDidEnterBackgroundCallback:(NSNotification *)notification;

- (id)keyForSection:(NSUInteger)section;
- (void)setNextPage:(NSUInteger)nextPage forSection:(NSUInteger)section;
- (BOOL)needsToDownloadNextDataInSection:(NSUInteger)section;
- (NSUInteger)nextPageForSection:(NSUInteger)section;

- (void)downloadDataForPage:(NSUInteger)page inSection:(NSUInteger)section;

@end



@interface GHTableViewController (iPad)

- (void)setupDefaultTableViewCell:(GHPDefaultTableViewCell *)cell inTableView:(UITableView *)tableView forRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)setupDefaultTableViewCell:(GHPDefaultTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath;
- (GHPDefaultTableViewCell *)defaultTableViewCellForRowAtIndexPath:(NSIndexPath *)indexPath withReuseIdentifier:(NSString *)CellIdentifier;
- (GHPCollapsingAndSpinningTableViewCell *)defaultPadCollapsingAndSpinningTableViewCellForSection:(NSUInteger)section;

@end



@interface GHTableViewController (GHHeightCaching)

- (void)cacheHeight:(CGFloat)height forRowAtIndexPath:(NSIndexPath *)indexPath;
- (CGFloat)cachedHeightForRowAtIndexPath:(NSIndexPath *)indexPath;
- (BOOL)isHeightCachedForRowAtIndexPath:(NSIndexPath *)indexPath;

@end
