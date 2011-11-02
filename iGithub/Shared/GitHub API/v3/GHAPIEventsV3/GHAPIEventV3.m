//
//  GHAPIEventV3.m
//  iGithub
//
//  Created by Oliver Letterer on 02.11.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GithubAPI.h"

NSString *const GHAPIEventV3TypeCommitComment = @"CommitComment";
NSString *const GHAPIEventV3TypeCreateEvent = @"CreateEvent";
NSString *const GHAPIEventV3TypeDeleteEvent = @"DeleteEvent";
NSString *const GHAPIEventV3TypeDownloadEvent = @"DownloadEvent";
NSString *const GHAPIEventV3TypeFollowEvent = @"FollowEvent";
NSString *const GHAPIEventV3TypeForkEvent = @"ForkEvent";
NSString *const GHAPIEventV3TypeForkApplyEvent = @"ForkApplyEvent";
NSString *const GHAPIEventV3TypeGistEvent = @"GistEvent";
NSString *const GHAPIEventV3TypeGollumEvent = @"GollumEvent";
NSString *const GHAPIEventV3TypeIssueCommentEvent = @"IssueCommentEvent";
NSString *const GHAPIEventV3TypeIssuesEvent = @"IssuesEvent";
NSString *const GHAPIEventV3TypeMemberEvent = @"MemberEvent";
NSString *const GHAPIEventV3TypePublicEvent = @"PublicEvent";
NSString *const GHAPIEventV3TypePullRequestEvent = @"PullRequestEvent";
NSString *const GHAPIEventV3TypePushEvent = @"PushEvent";
NSString *const GHAPIEventV3TypeTeamAddEvent = @"TeamAddEvent";
NSString *const GHAPIEventV3TypeWatchEvent = @"WatchEvent";

GHAPIEventTypeV3 GHAPIEventTypeV3FromNSString(NSString *eventType)
{
    GHAPIEventTypeV3 type = GHAPIEventTypeV3Unkown;
    
    if ([eventType isEqualToString:GHAPIEventV3TypeCommitComment]) {
        type = GHAPIEventTypeV3CommitComment;
    } else if ([eventType isEqualToString:GHAPIEventV3TypeCreateEvent]) {
        type = GHAPIEventTypeV3CreateEvent;
    } else if ([eventType isEqualToString:GHAPIEventV3TypeDeleteEvent]) {
        type = GHAPIEventTypeV3DeleteEvent;
    } else if ([eventType isEqualToString:GHAPIEventV3TypeDownloadEvent]) {
        type = GHAPIEventTypeV3DownloadEvent;
    } else if ([eventType isEqualToString:GHAPIEventV3TypeFollowEvent]) {
        type = GHAPIEventTypeV3FollowEvent;
    } else if ([eventType isEqualToString:GHAPIEventV3TypeForkEvent]) {
        type = GHAPIEventTypeV3ForkEvent;
    } else if ([eventType isEqualToString:GHAPIEventV3TypeForkApplyEvent]) {
        type = GHAPIEventTypeV3ForkApplyEvent;
    } else if ([eventType isEqualToString:GHAPIEventV3TypeGistEvent]) {
        type = GHAPIEventTypeV3GistEvent;
    } else if ([eventType isEqualToString:GHAPIEventV3TypeGollumEvent]) {
        type = GHAPIEventTypeV3GollumEvent;
    } else if ([eventType isEqualToString:GHAPIEventV3TypeIssueCommentEvent]) {
        type = GHAPIEventTypeV3IssueCommentEvent;
    } else if ([eventType isEqualToString:GHAPIEventV3TypeIssuesEvent]) {
        type = GHAPIEventTypeV3IssuesEvent;
    } else if ([eventType isEqualToString:GHAPIEventV3TypeMemberEvent]) {
        type = GHAPIEventTypeV3MemberEvent;
    } else if ([eventType isEqualToString:GHAPIEventV3TypePublicEvent]) {
        type = GHAPIEventTypeV3PublicEvent;
    } else if ([eventType isEqualToString:GHAPIEventV3TypePullRequestEvent]) {
        type = GHAPIEventTypeV3PullRequestEvent;
    } else if ([eventType isEqualToString:GHAPIEventV3TypePushEvent]) {
        type = GHAPIEventTypeV3PushEvent;
    } else if ([eventType isEqualToString:GHAPIEventV3TypeTeamAddEvent]) {
        type = GHAPIEventTypeV3TeamAddEvent;
    } else if ([eventType isEqualToString:GHAPIEventV3TypeWatchEvent]) {
        type = GHAPIEventTypeV3WatchEvent;
    } else {
        type = GHAPIEventTypeV3Unkown;
    }
    
    return type;
}


@implementation GHAPIEventV3
@synthesize repository=_repository, actor=_actor, organization=_organization, createdAtString=_createdAtString, typeString=_typeString, public=_public, type=_type;

#pragma mark - Initialization

- (id)initWithRawDictionary:(NSDictionary *)rawDictionary
{
    GHAPIObjectExpectedClass(&rawDictionary, NSDictionary.class);
    if (self = [super init]) {
        // Initialization code
        _repository = [[GHAPIRepositoryV3 alloc] initWithRawDictionary:[rawDictionary objectForKeyOrNilOnNullObject:@"repo"]];
        _actor = [[GHAPIUserV3 alloc] initWithRawDictionary:[rawDictionary objectForKeyOrNilOnNullObject:@"actor"]];
        _organization = [[GHAPIOrganizationV3 alloc] initWithRawDictionary:[rawDictionary objectForKeyOrNilOnNullObject:@"org"]];
        
        _createdAtString = [rawDictionary objectForKeyOrNilOnNullObject:@"created_at"];
        _typeString = [rawDictionary objectForKeyOrNilOnNullObject:@"type"];
        _public = [rawDictionary objectForKeyOrNilOnNullObject:@"public"];
        
        _type = GHAPIEventTypeV3FromNSString(_typeString);
        NSAssert(_type != GHAPIEventTypeV3Unkown, @"_typeString (%@) cannot be unkown", _typeString);
    }
    return self;
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:_repository forKey:@"repository"];
    [encoder encodeObject:_actor forKey:@"actor"];
    [encoder encodeObject:_organization forKey:@"organization"];
    [encoder encodeObject:_createdAtString forKey:@"createdAtString"];
    [encoder encodeObject:_typeString forKey:@"typeString"];
    [encoder encodeObject:_public forKey:@"public"];
    [encoder encodeInteger:_type forKey:@"type"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super init])) {
        _repository = [decoder decodeObjectForKey:@"repository"];
        _actor = [decoder decodeObjectForKey:@"actor"];
        _organization = [decoder decodeObjectForKey:@"organization"];
        _createdAtString = [decoder decodeObjectForKey:@"createdAtString"];
        _typeString = [decoder decodeObjectForKey:@"typeString"];
        _public = [decoder decodeObjectForKey:@"public"];
        _type = [decoder decodeIntegerForKey:@"type"];
    }
    return self;
}

@end
