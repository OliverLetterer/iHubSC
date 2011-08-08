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
    GHAPIObjectExpectedClass(&rawDictionary, NSDictionary.class);
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
        self.issueUser = [[GHUser alloc] initWithRawDictionary:[rawDictionary objectForKeyOrNilOnNullObject:@"issue_user"] ];
        self.labels = [rawDictionary objectForKeyOrNilOnNullObject:@"labels"];
        self.number = [rawDictionary objectForKeyOrNilOnNullObject:@"number"];
        self.patchURL = [rawDictionary objectForKeyOrNilOnNullObject:@"patch_url"];
        self.position = [rawDictionary objectForKeyOrNilOnNullObject:@"position"];
        self.state = [rawDictionary objectForKeyOrNilOnNullObject:@"state"];
        self.title = [rawDictionary objectForKeyOrNilOnNullObject:@"title"];
        self.updatedAt = [rawDictionary objectForKeyOrNilOnNullObject:@"updated_at"];
        self.user = [[GHUser alloc] initWithRawDictionary:[rawDictionary objectForKeyOrNilOnNullObject:@"user"] ];
        self.votes = [rawDictionary objectForKeyOrNilOnNullObject:@"votes"];
        
        self.base = [[GHPullRequestRepositoryInformation alloc] initWithRawDictionary:[rawDictionary objectForKeyOrNilOnNullObject:@"base"] ];
        self.head = [[GHPullRequestRepositoryInformation alloc] initWithRawDictionary:[rawDictionary objectForKeyOrNilOnNullObject:@"head"] ];
        
        NSMutableArray *commits = [NSMutableArray array];
        NSMutableArray *comments = [NSMutableArray array];
        NSArray *discussions = [rawDictionary objectForKeyOrNilOnNullObject:@"discussion"];
        
        for (NSDictionary *discussionDictionary in discussions) {
            if ([[discussionDictionary objectForKeyOrNilOnNullObject:@"type"] isEqualToString:@"Commit"]) {
                [commits addObject:[[GHCommit alloc] initWithRawDictionary:discussionDictionary] ];
            } else if ([[discussionDictionary objectForKeyOrNilOnNullObject:@"type"] isEqualToString:@"IssueComment"]) {
                [comments addObject:[[GHIssueComment alloc] initWithRawDictionary:discussionDictionary] ];
            }
        }
        
        self.commits = commits;
        self.commentsArray = comments;
    }
    return self;
}

#pragma mark - Memory management


#pragma mark - Keyed Archiving

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:_base forKey:@"base"];
    [encoder encodeObject:_head forKey:@"head"];
    [encoder encodeObject:_commits forKey:@"commits"];
    [encoder encodeObject:_commentsArray forKey:@"commentsArray"];
    [encoder encodeObject:_body forKey:@"body"];
    [encoder encodeObject:_comments forKey:@"comments"];
    [encoder encodeObject:_createdAt forKey:@"createdAt"];
    [encoder encodeObject:_diffURL forKey:@"diffURL"];
    [encoder encodeObject:_gravatarID forKey:@"gravatarID"];
    [encoder encodeObject:_htmlURL forKey:@"htmlURL"];
    [encoder encodeObject:_issueCreatedAt forKey:@"issueCreatedAt"];
    [encoder encodeObject:_issueUpdatedAt forKey:@"issueUpdatedAt"];
    [encoder encodeObject:_issueUser forKey:@"issueUser"];
    [encoder encodeObject:_labels forKey:@"labels"];
    [encoder encodeObject:_number forKey:@"number"];
    [encoder encodeObject:_patchURL forKey:@"patchURL"];
    [encoder encodeObject:_position forKey:@"position"];
    [encoder encodeObject:_state forKey:@"state"];
    [encoder encodeObject:_title forKey:@"title"];
    [encoder encodeObject:_updatedAt forKey:@"updatedAt"];
    [encoder encodeObject:_user forKey:@"user"];
    [encoder encodeObject:_votes forKey:@"votes"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super init])) {
        _base = [decoder decodeObjectForKey:@"base"];
        _head = [decoder decodeObjectForKey:@"head"];
        _commits = [decoder decodeObjectForKey:@"commits"];
        _commentsArray = [decoder decodeObjectForKey:@"commentsArray"];
        _body = [decoder decodeObjectForKey:@"body"];
        _comments = [decoder decodeObjectForKey:@"comments"];
        _createdAt = [decoder decodeObjectForKey:@"createdAt"];
        _diffURL = [decoder decodeObjectForKey:@"diffURL"];
        _gravatarID = [decoder decodeObjectForKey:@"gravatarID"];
        _htmlURL = [decoder decodeObjectForKey:@"htmlURL"];
        _issueCreatedAt = [decoder decodeObjectForKey:@"issueCreatedAt"];
        _issueUpdatedAt = [decoder decodeObjectForKey:@"issueUpdatedAt"];
        _issueUser = [decoder decodeObjectForKey:@"issueUser"];
        _labels = [decoder decodeObjectForKey:@"labels"];
        _number = [decoder decodeObjectForKey:@"number"];
        _patchURL = [decoder decodeObjectForKey:@"patchURL"];
        _position = [decoder decodeObjectForKey:@"position"];
        _state = [decoder decodeObjectForKey:@"state"];
        _title = [decoder decodeObjectForKey:@"title"];
        _updatedAt = [decoder decodeObjectForKey:@"updatedAt"];
        _user = [decoder decodeObjectForKey:@"user"];
        _votes = [decoder decodeObjectForKey:@"votes"];
    }
    return self;
}

@end
