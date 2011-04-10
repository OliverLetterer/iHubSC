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

@interface GHUserViewController : GHTableViewController <GHCreateRepositoryViewControllerDelegate, GHSingleRepositoryViewControllerDelegate> {
@private
    NSArray *_repositoriesArray;
    NSString *_username;
    
    BOOL _isShowingWatchedRepositories;
    BOOL _shouldShowWatchedRepositoriesAfterDownload;
    BOOL _isDownloadingWatchedRepositories;
    NSArray *_watchedRepositoriesArray;
    
    NSIndexPath *_lastIndexPathForSingleRepositoryViewController;
}

@property (nonatomic, retain) NSArray *repositoriesArray;
@property (nonatomic, copy) NSString *username;
@property (nonatomic, retain) NSArray *watchedRepositoriesArray;
@property (nonatomic, copy) NSIndexPath *lastIndexPathForSingleRepositoryViewController;

- (id)initWithUsername:(NSString *)username;

- (void)downloadRepositories;

- (void)cacheHeightForTableView;
- (void)cacheHeightForWatchedRepositories;

- (void)createRepositoryButtonClicked:(UIBarButtonItem *)button;

- (void)downloadWatchedRepositories;
- (void)showWatchedRepositories;
- (void)hideWatchedRepositories;

@end
