//
//  GHNewsFeedItem.m
//  iGithub
//
//  Created by Oliver Letterer on 01.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHNewsFeedItem.h"
#import "GithubAPI.h"

@implementation GHNewsFeedItem

@synthesize actor=_actor, actorAttributes=_actorAttributes, creationDate=_creationDate, payload=_payload, public=_public, repository=_repository, times=_times, type=_type, URL=_URL;

#pragma mark - Initialization

- (id)initWithRawDictionary:(NSDictionary *)rawDictionary {
    if ((self = [super init])) {
        NSLog(@"%@", rawDictionary);
        // Initialization code
        self.actor = [rawDictionary objectForKey:@"actor"];
        self.creationDate = [rawDictionary objectForKey:@"created_at"];
        self.public = [rawDictionary objectForKey:@"public"];
        self.times = [rawDictionary objectForKey:@"times"];
        self.type = [rawDictionary objectForKey:@"type"];
        self.URL = [rawDictionary objectForKey:@"url"];
        
        self.actorAttributes = [[[GHActorAttributes alloc] initWithRawDictionary:[rawDictionary objectForKey:@"actor_attributes"]] autorelease];
        self.repository = [[[GHRepository alloc] initWithRawDictionary:[rawDictionary objectForKey:@"repository"]] autorelease];
        
        NSDictionary *rawPayload = [rawDictionary objectForKey:@"payload"];
        if ([self.type isEqualToString:@"PullRequestEvent"]) {
            self.payload = [[[GHPullRequestPayload alloc] initWithRawDictionary:rawPayload] autorelease];
        } else if ([self.type isEqualToString:@"PushEvent"]) {
            self.payload = [[[GHPushPayload alloc] initWithRawDictionary:rawPayload] autorelease];
        } else if ([self.type isEqualToString:@"IssuesEvent"]) {
            self.payload = [[[GHIssuePayload alloc] initWithRawDictionary:rawPayload] autorelease];
        } else if ([self.type isEqualToString:@"CommitCommentEvent"]) {
            self.payload = [[[GHCommitEventPayload alloc] initWithRawDictionary:rawPayload] autorelease];
        } else if ([self.type isEqualToString:@"FollowEvent"]) {
            self.payload = [[[GHFollowEventPayload alloc] initWithRawDictionary:rawPayload] autorelease];
        } else if ([self.type isEqualToString:@"WatchEvent"]) {
            self.payload = [[[GHWatchEventPayload alloc] initWithRawDictionary:rawPayload] autorelease];
        }
    }
    return self;
}

#pragma mark - Memory management

- (void)dealloc {
    [_actor release];
    [_actorAttributes release];
    [_creationDate release];
    [_payload release];
    [_public release];
    [_repository release];
    [_times release];
    [_type release];
    [_URL release];
    
    [super dealloc];
}

@end
