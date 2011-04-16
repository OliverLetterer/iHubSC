//
//  GHPullRequestRepositoryInformation.m
//  iGithub
//
//  Created by Oliver Letterer on 16.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHPullRequestRepositoryInformation.h"


@implementation GHPullRequestRepositoryInformation

@synthesize label=_label, ref=_ref, repository=_repository, sha=_sha, user=_user;

#pragma mark - Initialization

- (id)initWithRawDictionary:(NSDictionary *)rawDictionary {
    if ((self = [super init])) {
        // Initialization code
        self.label = [rawDictionary objectForKeyOrNilOnNullObject:@"label"];
        self.ref = [rawDictionary objectForKeyOrNilOnNullObject:@"ref"];
        self.sha = [rawDictionary objectForKeyOrNilOnNullObject:@"sha"];
        self.repository = [[[GHRepository alloc] initWithRawDictionary:[rawDictionary objectForKeyOrNilOnNullObject:@"repository"] ] autorelease];
        self.user = [[[GHUser alloc] initWithRawDictionary:[rawDictionary objectForKeyOrNilOnNullObject:@"user"] ] autorelease];
    }
    return self;
}

#pragma mark - Memory management

- (void)dealloc {
    [_label release];
    [_ref release];
    [_repository release];
    [_sha release];
    [_user release];
    [super dealloc];
}

@end
