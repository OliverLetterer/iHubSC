//
//  GHPullRequest.m
//  iGithub
//
//  Created by Oliver Letterer on 01.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHPullRequest.h"
#import "GithubAPI.h"

@implementation GHPullRequest

@synthesize additions=_additions, commits=_commits, deletions=_deletions, ID=_ID, issueID=_issueID, number=_number, title=_title;

#pragma mark - Initialization

- (id)initWithRawDictionary:(NSDictionary *)rawDictionary {
    if ((self = [super init])) {
        // Initialization code
        self.additions = [rawDictionary objectForKeyOrNilOnNullObject:@"additions"];
        self.commits = [rawDictionary objectForKeyOrNilOnNullObject:@"commits"];
        self.deletions = [rawDictionary objectForKeyOrNilOnNullObject:@"deletions"];
        self.ID = [rawDictionary objectForKeyOrNilOnNullObject:@"id"];
        self.issueID = [rawDictionary objectForKeyOrNilOnNullObject:@"issue_id"];
        self.number = [rawDictionary objectForKeyOrNilOnNullObject:@"number"];
        self.title = [rawDictionary objectForKeyOrNilOnNullObject:@"title"];
    }
    return self;
}

#pragma mark - Memory management

- (void)dealloc {
    [_additions release];
    [_commits release];
    [_deletions release];
    [_ID release];
    [_issueID release];
    [_number release];
    [_title release];
    [super dealloc];
}

@end
