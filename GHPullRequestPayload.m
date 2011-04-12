//
//  GHPullRequestPayload.m
//  iGithub
//
//  Created by Oliver Letterer on 01.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHPullRequestPayload.h"
#import "GithubAPI.h"

@implementation GHPullRequestPayload

@synthesize number=_number, action=_action, pullRequest=_pullRequest;

#pragma mark - setters and getters

- (GHPayloadEvent)type {
    return GHPayloadPullRequestEvent;
}

#pragma mark - Initialization

- (id)initWithRawDictionary:(NSDictionary *)rawDictionary {
    if ((self = [super initWithRawDictionary:rawDictionary])) {
        self.number = [rawDictionary objectForKeyOrNilOnNullObject:@"number"];
        self.action = [rawDictionary objectForKeyOrNilOnNullObject:@"action"];
        NSObject *pullRequest = [rawDictionary objectForKeyOrNilOnNullObject:@"pull_request"];
        if ([[pullRequest class] isSubclassOfClass:NSClassFromString(@"NSDictionary")]) {
            self.pullRequest = [[[GHPullRequest alloc] initWithRawDictionary:(NSDictionary *)pullRequest] autorelease];
        }
        // Initialization code
        
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
