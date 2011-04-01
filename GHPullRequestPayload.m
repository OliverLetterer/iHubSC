//
//  GHPullRequestPayload.m
//  iGithub
//
//  Created by Oliver Letterer on 01.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHPullRequestPayload.h"


@implementation GHPullRequestPayload

@synthesize number=_number, action=_action, pullRequest=_pullRequest;

#pragma mark - setters and getters

- (GHPayloadType)type {
    return GHPayloadTypePullRequest;
}

#pragma mark - Initialization

- (id)initWithRawDictionary:(NSDictionary *)rawDictionary {
    if ((self = [super initWithRawDictionary:rawDictionary])) {
        // Initialization code
        self.number = [rawDictionary objectForKey:@"number"];
        self.action = [rawDictionary objectForKey:@"action"];
        self.pullRequest = [[[GHPullRequest alloc] initWithRawDictionary:[rawDictionary objectForKey:@"pull_request"]] autorelease];
    }
    return self;
}

#pragma mark - Memory management

- (void)dealloc {
    [_number release];
    [_action release];
    [_pullRequest release];
    [super dealloc];
}

@end
