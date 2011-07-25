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
    rawDictionary = NSObjectExpectedClass(rawDictionary, NSDictionary.class);
    if ((self = [super init])) {
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
        } else if ([self.type isEqualToString:@"MemberEvent"]) {
            self.payload = [[[GHMemberEventPayload alloc] initWithRawDictionary:rawPayload] autorelease];
        } else if ([self.type isEqualToString:@"IssueCommentEvent"]) {
            self.payload = [[[GHIssuesCommentPayload alloc] initWithRawDictionary:rawPayload URL:self.URL] autorelease];
        } else if ([self.type isEqualToString:@"ForkApplyEvent"]) {
            self.payload = [[[GHForkApplyEventPayload alloc] initWithRawDictionary:rawPayload] autorelease];
        } else if ([self.type isEqualToString:@"PublicEvent"]) {
            self.payload = [[[GHPublicEventPayload alloc] initWithRawDictionary:rawPayload] autorelease];
        } else {
#if DEBUG
            [[NSNotificationCenter defaultCenter] postNotificationName:@"GHUnknownPayloadEventType" object:nil userInfo:rawDictionary];
#endif
            
            DLog(@"Unknown Payload Event Type");
            DLog(@"%@", rawDictionary);
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

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.actor forKey:@"actor"];
    [aCoder encodeObject:self.actorAttributes forKey:@"actorAttributes"];
    [aCoder encodeObject:self.creationDate forKey:@"creationDate"];
    [aCoder encodeObject:self.payload forKey:@"payload"];
    [aCoder encodeObject:self.public forKey:@"public"];
    [aCoder encodeObject:self.repository forKey:@"repository"];
    [aCoder encodeObject:self.times forKey:@"times"];
    [aCoder encodeObject:self.type forKey:@"type"];
    [aCoder encodeObject:self.URL forKey:@"URL"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.actor = [aDecoder decodeObjectForKey:@"actor"];
        self.actorAttributes = [aDecoder decodeObjectForKey:@"actorAttributes"];
        self.creationDate = [aDecoder decodeObjectForKey:@"creationDate"];
        self.payload = [aDecoder decodeObjectForKey:@"payload"];
        self.public = [aDecoder decodeObjectForKey:@"public"];
        self.repository = [aDecoder decodeObjectForKey:@"repository"];
        self.times = [aDecoder decodeObjectForKey:@"times"];
        self.type = [aDecoder decodeObjectForKey:@"type"];
        self.URL = [aDecoder decodeObjectForKey:@"URL"];
    }
    return self;
}

@end
