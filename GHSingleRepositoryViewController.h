//
//  GHSingleRepositoryViewController.h
//  iGithub
//
//  Created by Oliver Letterer on 09.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GHTableViewController.h"
#import "GithubAPI.h"

@class GHSingleRepositoryViewController;

@protocol GHSingleRepositoryViewControllerDelegate <NSObject>

- (void)singleRepositoryViewControllerDidDeleteRepository:(GHSingleRepositoryViewController *)singleRepositoryViewController;

@end





@interface GHSingleRepositoryViewController : GHTableViewController <UIAlertViewDelegate, GHSingleRepositoryViewControllerDelegate> {
@private
    NSString *_repositoryString;
    GHRepository *_repository;
    
    BOOL _isShowingIssues;
    BOOL _isDownloadIssues;
    NSArray *_issuesArray;
    
    BOOL _isShowingWatchedUsers;
    BOOL _isDownloadingWatchedUsers;
    NSArray *_watchedUsersArray;
    
    BOOL _isShowingAdminsitration;
    
    NSString *_deleteToken;
    
    id<GHSingleRepositoryViewControllerDelegate> _delegate;
}

@property (nonatomic, readonly) BOOL canDeleteRepository;

@property (nonatomic, copy) NSString *repositoryString;
@property (nonatomic, retain) GHRepository *repository;

@property (nonatomic, retain) NSArray *issuesArray;
- (void)showIssues;
- (void)hideIssues;
- (void)downloadIssues;
- (void)cacheHeightForIssuesArray;

@property (nonatomic, retain) NSArray *watchedUsersArray;
- (void)showWatchedUsers;
- (void)hideWatchedUsers;
- (void)downloadWatchedUsers;

- (void)showAdminsitration;
- (void)hideAdminsitration;

@property (nonatomic, copy) NSString *deleteToken;
@property (nonatomic, assign) id<GHSingleRepositoryViewControllerDelegate> delegate;

- (id)initWithRepositoryString:(NSString *)repositoryString;

@end
