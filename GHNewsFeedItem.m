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
#warning remove debugging
        NSLog(@"%@", rawDictionary);
        // Initialization code
        self.actor = [rawDictionary objectForKeyOrNilOnNullObject:@"actor"];
        self.creationDate = [rawDictionary objectForKeyOrNilOnNullObject:@"created_at"];
        self.public = [rawDictionary objectForKeyOrNilOnNullObject:@"public"];
        self.times = [rawDictionary objectForKeyOrNilOnNullObject:@"times"];
        self.type = [rawDictionary objectForKeyOrNilOnNullObject:@"type"];
        self.URL = [rawDictionary objectForKeyOrNilOnNullObject:@"url"];
        
        self.actorAttributes = [[[GHActorAttributes alloc] initWithRawDictionary:[rawDictionary objectForKeyOrNilOnNullObject:@"actor_attributes"]] autorelease];
        self.repository = [[[GHRepository alloc] initWithRawDictionary:[rawDictionary objectForKeyOrNilOnNullObject:@"repository"]] autorelease];
        
        NSDictionary *rawPayload = [rawDictionary objectForKeyOrNilOnNullObject:@"payload"];
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
        } else if ([self.type isEqualToString:@"CreateEvent"]) {
            self.payload = [[[GHCreateEventPayload alloc] initWithRawDictionary:rawPayload] autorelease];
        } else if ([self.type isEqualToString:@"ForkEvent"]) {
            self.payload = [[[GHForkEventPayload alloc] initWithRawDictionary:rawPayload] autorelease];
        } else if ([self.type isEqualToString:@"DeleteEvent"]) {
            self.payload = [[[GHDeleteEventPayload alloc] initWithRawDictionary:rawPayload] autorelease];
        } else if ([self.type isEqualToString:@"GollumEvent"]) {
            self.payload = [[[GHGollumEventPayload alloc] initWithRawDictionary:rawPayload] autorelease];
        } else if ([self.type isEqualToString:@"GistEvent"]) {
            self.payload = [[[GHGistEventPayload alloc] initWithRawDictionary:rawPayload] autorelease];
        } else if ([self.type isEqualToString:@"DownloadEvent"]) {
            self.payload = [[[GHDownloadEventPayload alloc] initWithRawDictionary:rawPayload] autorelease];
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
