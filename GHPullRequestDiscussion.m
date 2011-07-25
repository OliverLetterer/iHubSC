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
    rawDictionary = GHAPIObjectExpectedClass(rawDictionary, NSDictionary.class);
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
        _base = [[decoder decodeObjectForKey:@"base"] retain];
        _head = [[decoder decodeObjectForKey:@"head"] retain];
        _commits = [[decoder decodeObjectForKey:@"commits"] retain];
        _commentsArray = [[decoder decodeObjectForKey:@"commentsArray"] retain];
        _body = [[decoder decodeObjectForKey:@"body"] retain];
        _comments = [[decoder decodeObjectForKey:@"comments"] retain];
        _createdAt = [[decoder decodeObjectForKey:@"createdAt"] retain];
        _diffURL = [[decoder decodeObjectForKey:@"diffURL"] retain];
        _gravatarID = [[decoder decodeObjectForKey:@"gravatarID"] retain];
        _htmlURL = [[decoder decodeObjectForKey:@"htmlURL"] retain];
        _issueCreatedAt = [[decoder decodeObjectForKey:@"issueCreatedAt"] retain];
        _issueUpdatedAt = [[decoder decodeObjectForKey:@"issueUpdatedAt"] retain];
        _issueUser = [[decoder decodeObjectForKey:@"issueUser"] retain];
        _labels = [[decoder decodeObjectForKey:@"labels"] retain];
        _number = [[decoder decodeObjectForKey:@"number"] retain];
        _patchURL = [[decoder decodeObjectForKey:@"patchURL"] retain];
        _position = [[decoder decodeObjectForKey:@"position"] retain];
        _state = [[decoder decodeObjectForKey:@"state"] retain];
        _title = [[decoder decodeObjectForKey:@"title"] retain];
        _updatedAt = [[decoder decodeObjectForKey:@"updatedAt"] retain];
        _user = [[decoder decodeObjectForKey:@"user"] retain];
        _votes = [[decoder decodeObjectForKey:@"votes"] retain];
    }
    return self;
}

@end
