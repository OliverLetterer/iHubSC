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
    
    NSArray *_issuesArray;
    
    NSMutableArray *_watchedUsersArray;
    
    NSString *_deleteToken;
    
    id<GHSingleRepositoryViewControllerDelegate> _delegate;
}

@property (nonatomic, readonly) BOOL isFollowingRepository;
@property (nonatomic, readonly) BOOL canDeleteRepository;

@property (nonatomic, copy) NSString *repositoryString;
@property (nonatomic, retain) GHRepository *repository;

@property (nonatomic, retain) NSArray *issuesArray;
- (void)cacheHeightForIssuesArray;

@property (nonatomic, retain) NSMutableArray *watchedUsersArray;

@property (nonatomic, copy) NSString *deleteToken;
@property (nonatomic, assign) id<GHSingleRepositoryViewControllerDelegate> delegate;

- (id)initWithRepositoryString:(NSString *)repositoryString;

@end
