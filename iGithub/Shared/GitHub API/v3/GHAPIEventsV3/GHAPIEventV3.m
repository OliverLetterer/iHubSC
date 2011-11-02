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



@implementation GHAPIEventV3
@synthesize repository=_repository, actor=_actor, organization=_organization, createdAtString=_createdAtString, typeString=_typeString, public=_public;

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
        
        if ([_typeString isEqualToString:GHAPIEventV3TypeCommitComment]) {
            _type = GHAPIEventTypeV3CommitComment;
        } else if ([_typeString isEqualToString:GHAPIEventV3TypeCreateEvent]) {
            _type = GHAPIEventTypeV3CreateEvent;
        } else if ([_typeString isEqualToString:GHAPIEventV3TypeDeleteEvent]) {
            _type = GHAPIEventTypeV3DeleteEvent;
        } else if ([_typeString isEqualToString:GHAPIEventV3TypeDownloadEvent]) {
            _type = GHAPIEventTypeV3DownloadEvent;
        } else if ([_typeString isEqualToString:GHAPIEventV3TypeFollowEvent]) {
            _type = GHAPIEventTypeV3FollowEvent;
        } else if ([_typeString isEqualToString:GHAPIEventV3TypeForkEvent]) {
            _type = GHAPIEventTypeV3ForkEvent;
        } else if ([_typeString isEqualToString:GHAPIEventV3TypeForkApplyEvent]) {
            _type = GHAPIEventTypeV3ForkApplyEvent;
        } else if ([_typeString isEqualToString:GHAPIEventV3TypeGistEvent]) {
            _type = GHAPIEventTypeV3GistEvent;
        } else if ([_typeString isEqualToString:GHAPIEventV3TypeGollumEvent]) {
            _type = GHAPIEventTypeV3GollumEvent;
        } else if ([_typeString isEqualToString:GHAPIEventV3TypeIssueCommentEvent]) {
            _type = GHAPIEventTypeV3IssueCommentEvent;
        } else if ([_typeString isEqualToString:GHAPIEventV3TypeIssuesEvent]) {
            _type = GHAPIEventTypeV3IssuesEvent;
        } else if ([_typeString isEqualToString:GHAPIEventV3TypeMemberEvent]) {
            _type = GHAPIEventTypeV3MemberEvent;
        } else if ([_typeString isEqualToString:GHAPIEventV3TypePublicEvent]) {
            _type = GHAPIEventTypeV3PublicEvent;
        } else if ([_typeString isEqualToString:GHAPIEventV3TypePullRequestEvent]) {
            _type = GHAPIEventTypeV3PullRequestEvent;
        } else if ([_typeString isEqualToString:GHAPIEventV3TypePushEvent]) {
            _type = GHAPIEventTypeV3PushEvent;
        } else if ([_typeString isEqualToString:GHAPIEventV3TypeTeamAddEvent]) {
            _type = GHAPIEventTypeV3TeamAddEvent;
        } else if ([_typeString isEqualToString:GHAPIEventV3TypeWatchEvent]) {
            _type = GHAPIEventTypeV3WatchEvent;
        } else {
            NSAssert(NO, @"_typeString (%@) in GHAPIEventV3 is of unknown type", _typeString);
        }
    }
    return self;
}

@end
