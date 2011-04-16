//
//  GHPullRequestDiscussion.m
//  iGithub
//
//  Created by Oliver Letterer on 16.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHPullRequestDiscussion.h"


@implementation GHPullRequestDiscussion

@synthesize base=_base, head=_head, issueUser=_issueUser, labels=_labels, user=_user, body=_body, comments=_comments, createdAt=_createdAt, diffURL=_diffURL, gravatarID=_gravatarID, htmlURL=_htmlURL, issueCreatedAt=_issueCreatedAt, issueUpdatedAt=_issueUpdatedAt, number=_number, patchURL=_patchURL, position=_position, state=_state, title=_title, updatedAt=_updatedAt, votes=_votes;
@synthesize commits=_commits, commentsArray=_commentsArray;

#pragma mark - Initialization

- (id)initWithRawDictionary:(NSDictionary *)rawDictionary {
    if ((self = [super init])) {
        // Initialization code
        self.body = [rawDictionary objectForKeyOrNilOnNullObject:@"body"];
        self.comments = [rawDictionary objectForKeyOrNilOnNullObject:@"comments"];
        self.createdAt = [rawDictionary objectForKeyOrNilOnNullObject:@"created_at"];
        self.diffURL = [rawDictionary objectForKeyOrNilOnNullObject:@"diff_url"];
        self.gravatarID = [rawDictionary objectForKeyOrNilOnNullObject:@"gravatar_id"];
        self.htmlURL = [rawDictionary objectForKeyOrNilOnNullObject:@"html_url"];
        self.issueCreatedAt = [rawDictionary objectForKeyOrNilOnNullObject:@"issue_created_at"];
        self.issueUpdatedAt = [rawDictionary objectForKeyOrNilOnNullObject:@"issue_updated_at"];
        self.issueUser = [[[GHUser alloc] initWithRawDictionary:[rawDictionary objectForKeyOrNilOnNullObject:@"issue_user"] ] autorelease];
        self.labels = [rawDictionary objectForKeyOrNilOnNullObject:@"labels"];
        self.number = [rawDictionary objectForKeyOrNilOnNullObject:@"number"];
        self.patchURL = [rawDictionary objectForKeyOrNilOnNullObject:@"patch_url"];
        self.position = [rawDictionary objectForKeyOrNilOnNullObject:@"position"];
        self.state = [rawDictionary objectForKeyOrNilOnNullObject:@"state"];
        self.title = [rawDictionary objectForKeyOrNilOnNullObject:@"title"];
        self.updatedAt = [rawDictionary objectForKeyOrNilOnNullObject:@"updated_at"];
        self.user = [[[GHUser alloc] initWithRawDictionary:[rawDictionary objectForKeyOrNilOnNullObject:@"user"] ] autorelease];
        self.votes = [rawDictionary objectForKeyOrNilOnNullObject:@"votes"];
        
        self.base = [[[GHPullRequestRepositoryInformation alloc] initWithRawDictionary:[rawDictionary objectForKeyOrNilOnNullObject:@"base"] ] autorelease];
        self.head = [[[GHPullRequestRepositoryInformation alloc] initWithRawDictionary:[rawDictionary objectForKeyOrNilOnNullObject:@"head"] ] autorelease];
        
        NSMutableArray *commits = [NSMutableArray array];
        NSMutableArray *comments = [NSMutableArray array];
        NSArray *discussions = [rawDictionary objectForKeyOrNilOnNullObject:@"discussion"];
        
        for (NSDictionary *discussionDictionary in discussions) {
            if ([[discussionDictionary objectForKeyOrNilOnNullObject:@"type"] isEqualToString:@"Commit"]) {
                [commits addObject:[[[GHCommit alloc] initWithRawDictionary:discussionDictionary] autorelease] ];
            } else if ([[discussionDictionary objectForKeyOrNilOnNullObject:@"type"] isEqualToString:@"IssueComment"]) {
                [comments addObject:[[[GHIssueComment alloc] initWithRawDictionary:discussionDictionary] autorelease] ];
            }
        }
        
        self.commits = commits;
        self.commentsArray = comments;
        
        DLog(@"%@", rawDictionary);
    }
    return self;
}

#pragma mark - Memory management

- (void)dealloc {
    [_base release];
    [_head release];
    [_issueUser release];
    [_labels release];
    [_user release];
    [_body release];
    [_comments release];
    [_createdAt release];
    [_diffURL release];
    [_gravatarID release];
    [_htmlURL release];
    [_issueCreatedAt release];
    [_issueUpdatedAt release];
    [_number release];
    [_patchURL release];
    [_position release];
    [_state release];
    [_title release];
    [_updatedAt release];
    [_votes release];
    [_commits release];
    [_commentsArray release];
    [super dealloc];
}

@end
