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





@interface GHSingleRepositoryViewController : GHTableViewController <UIAlertViewDelegate, GHSingleRepositoryViewControllerDelegate, GHCreateIssueTableViewControllerDelegate> {
@private
    NSString *_repositoryString;
    GHRepository *_repository;
    
    NSArray *_issuesArray;
    NSInteger _issuesNextPage;
    
    NSMutableArray *_watchedUsersArray;
    
    NSString *_deleteToken;
    
    id<GHSingleRepositoryViewControllerDelegate> _delegate;
    
    NSArray *_pullRequests;
    NSArray *_branches;
    
    NSArray *_milestones;
    NSInteger _milstonesNextPage;
}

@property (nonatomic, readonly) BOOL isFollowingRepository;
@property (nonatomic, readonly) BOOL canDeleteRepository;

@property (nonatomic, copy) NSString *repositoryString;
@property (nonatomic, retain) GHRepository *repository;

@property (nonatomic, retain) NSArray *issuesArray;
- (void)cacheHeightForIssuesArray;

@property (nonatomic, retain) NSArray *milestones;

@property (nonatomic, retain) NSMutableArray *watchedUsersArray;

@property (nonatomic, copy) NSString *deleteToken;
@property (nonatomic, assign) id<GHSingleRepositoryViewControllerDelegate> delegate;

@property (nonatomic, retain) NSArray *pullRequests;
- (void)cacheHeightForPullRequests;

@property (nonatomic, retain) NSArray *branches;

- (id)initWithRepositoryString:(NSString *)repositoryString;

@end
