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
#import "GHCreateIssueTableViewController.h"

@class GHSingleRepositoryViewController;

@protocol GHSingleRepositoryViewControllerDelegate <NSObject>

- (void)singleRepositoryViewControllerDidDeleteRepository:(GHSingleRepositoryViewController *)singleRepositoryViewController;

@end

#warning manage collaborators on a repository (delete and add)
#warning Network -> fork Repository to self/ Organization


@interface GHSingleRepositoryViewController : GHTableViewController <UIAlertViewDelegate, GHSingleRepositoryViewControllerDelegate, GHCreateIssueTableViewControllerDelegate> {
@private
    NSString *_repositoryString;
    GHAPIRepositoryV3 *_repository;
    
    NSMutableArray *_issuesArray;
    
    NSMutableArray *_watchedUsersArray;
    
    BOOL _hasWatchingData;
    BOOL _isWatchingRepository;
    
    NSString *_deleteToken;
    
    id<GHSingleRepositoryViewControllerDelegate> _delegate;
    
    NSArray *_pullRequests;
    NSMutableArray *_branches;
    NSMutableArray *_labels;
    
    NSMutableArray *_milestones;
}

@property (nonatomic, readonly) BOOL isFollowingRepository;
@property (nonatomic, readonly) BOOL canDeleteRepository;

@property (nonatomic, copy) NSString *repositoryString;
@property (nonatomic, retain) GHAPIRepositoryV3 *repository;

@property (nonatomic, retain) NSMutableArray *issuesArray;
- (void)cacheHeightForIssuesArray;

@property (nonatomic, retain) NSMutableArray *milestones;

@property (nonatomic, retain) NSMutableArray *watchedUsersArray;

@property (nonatomic, copy) NSString *deleteToken;
@property (nonatomic, assign) id<GHSingleRepositoryViewControllerDelegate> delegate;

@property (nonatomic, retain) NSArray *pullRequests;
- (void)cacheHeightForPullRequests;

@property (nonatomic, retain) NSMutableArray *branches;
@property (nonatomic, retain) NSMutableArray *labels;

- (id)initWithRepositoryString:(NSString *)repositoryString;

@end
