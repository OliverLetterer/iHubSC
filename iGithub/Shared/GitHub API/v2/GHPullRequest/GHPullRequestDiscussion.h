//
//  GHPullRequestDiscussion.h
//  iGithub
//
//  Created by Oliver Letterer on 16.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GithubAPI.h"

@class GHPullRequestRepositoryInformation;

@interface GHPullRequestDiscussion : NSObject <NSCoding> {
@private
    GHPullRequestRepositoryInformation *_base;
    GHPullRequestRepositoryInformation *_head;
    NSArray *_commits;
    NSArray *_commentsArray;
    NSString *_body;
    NSNumber *_comments;
    NSString *_createdAt;
    NSString *_diffURL;
    NSString *_gravatarID;
    NSString *_htmlURL;
    NSString *_issueCreatedAt;
    NSString *_issueUpdatedAt;
    GHUser *_issueUser;
    NSArray *_labels;
    NSNumber *_number;
    NSString *_patchURL;
    NSNumber *_position;
    NSString *_state;
    NSString *_title;
    NSString *_updatedAt;
    GHUser *_user;
    NSNumber *_votes;
}

@property (nonatomic, retain) GHPullRequestRepositoryInformation *base;
@property (nonatomic, retain) GHPullRequestRepositoryInformation *head;
@property (nonatomic, retain) NSArray *commits;         // contains GHCommit's
@property (nonatomic, retain) NSArray *commentsArray;   // contains GHIssueComment's
@property (nonatomic, retain) GHUser *issueUser;
@property (nonatomic, retain) GHUser *user;
@property (nonatomic, retain) NSArray *labels;
@property (nonatomic, copy) NSString *body;
@property (nonatomic, copy) NSNumber *comments;
@property (nonatomic, copy) NSString *createdAt;
@property (nonatomic, copy) NSString *diffURL;
@property (nonatomic, copy) NSString *gravatarID;
@property (nonatomic, copy) NSString *htmlURL;
@property (nonatomic, copy) NSString *issueCreatedAt;
@property (nonatomic, copy) NSString *issueUpdatedAt;
@property (nonatomic, copy) NSNumber *number;
@property (nonatomic, copy) NSString *patchURL;
@property (nonatomic, copy) NSNumber *position;
@property (nonatomic, copy) NSString *state;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *updatedAt;
@property (nonatomic, copy) NSNumber *votes;

- (id)initWithRawDictionary:(NSDictionary *)rawDictionary;

@end
