//
//  GHPullRequest.m
//  iGithub
//
//  Created by Oliver Letterer on 01.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHPullRequest.h"


@implementation GHPullRequest

@synthesize additions=_additions, commits=_commits, deletions=_deletions, ID=_ID, issueID=_issueID, number=_number, title=_title;

#pragma mark - Initialization

- (id)initWithRawDictionary:(NSDictionary *)rawDictionary {
    if ((self = [super init])) {
        // Initialization code
        self.additions = [rawDictionary objectForKey:@"additions"];
        self.commits = [rawDictionary objectForKey:@"commits"];
        self.deletions = [rawDictionary objectForKey:@"deletions"];
        self.ID = [rawDictionary objectForKey:@"id"];
        self.issueID = [rawDictionary objectForKey:@"issue_id"];
        self.number = [rawDictionary objectForKey:@"number"];
        self.title = [rawDictionary objectForKey:@"title"];
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
