//
//  GHUserViewController.h
//  iGithub
//
//  Created by Oliver Letterer on 06.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GHTableViewController.h"
#import "GHCreateRepositoryViewController.h"
#import "GHSingleRepositoryViewController.h"
#import "UIExpandableTableView.h"
#import "GithubAPI.h"

@interface GHUserViewController : GHTableViewController <GHCreateRepositoryViewControllerDelegate, GHSingleRepositoryViewControllerDelegate, UIAlertViewDelegate> {
@private
    NSString *_username;
    BOOL _isDownloadingUserData;
    GHAPIUserV3 *_user;
    
    NSMutableArray *_repositoriesArray;
    NSMutableArray *_watchedRepositoriesArray;
    NSMutableArray *_followingUsers;
    NSArray *_organizations;
    NSMutableArray *_followedUsers;
    NSMutableArray *_gists;
    
    BOOL _hasFollowingData;
    BOOL _isFollowingUser;
    
    NSIndexPath *_lastIndexPathForSingleRepositoryViewController;
}

@property (nonatomic, retain) GHAPIUserV3 *user;

@property (nonatomic, retain) NSMutableArray *repositoriesArray;
@property (nonatomic, copy) NSString *username;
@property (nonatomic, retain) NSMutableArray *watchedRepositoriesArray;
@property (nonatomic, retain) NSMutableArray *followingUsers;
@property (nonatomic, retain) NSArray *organizations;
@property (nonatomic, retain) NSMutableArray *followedUsers;
@property (nonatomic, retain) NSMutableArray *gists;

@property (nonatomic, readonly) BOOL canFollowUser;
@property (nonatomic, readonly) BOOL hasAdministrationRights;

@property (nonatomic, copy) NSIndexPath *lastIndexPathForSingleRepositoryViewController;

- (id)initWithUsername:(NSString *)username;

- (void)createRepositoryButtonClicked:(UIBarButtonItem *)button;
- (void)accountButtonClicked:(UIBarButtonItem *)button;

- (void)downloadUserData;
- (void)downloadRepositories;
- (void)cacheHeightForTableView;
- (void)cacheHeightForWatchedRepositories;
- (void)cacheGistsHeight;

@end
