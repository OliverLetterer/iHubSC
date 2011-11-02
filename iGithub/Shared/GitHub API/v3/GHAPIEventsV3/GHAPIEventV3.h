//
//  GHAPIEventV3.h
//  iGithub
//
//  Created by Oliver Letterer on 02.11.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHAPIRepositoryV3.h"
#import "GHAPIUserV3.h"
#import "GHAPIOrganizationV3.h"

extern NSString *const GHAPIEventV3TypeCommitComment;
extern NSString *const GHAPIEventV3TypeCreateEvent;
extern NSString *const GHAPIEventV3TypeDeleteEvent;
extern NSString *const GHAPIEventV3TypeDownloadEvent;
extern NSString *const GHAPIEventV3TypeFollowEvent;
extern NSString *const GHAPIEventV3TypeForkEvent;
extern NSString *const GHAPIEventV3TypeForkApplyEvent;
extern NSString *const GHAPIEventV3TypeGistEvent;
extern NSString *const GHAPIEventV3TypeGollumEvent;
extern NSString *const GHAPIEventV3TypeIssueCommentEvent;
extern NSString *const GHAPIEventV3TypeIssuesEvent;
extern NSString *const GHAPIEventV3TypeMemberEvent;
extern NSString *const GHAPIEventV3TypePublicEvent;
extern NSString *const GHAPIEventV3TypePullRequestEvent;
extern NSString *const GHAPIEventV3TypePushEvent;
extern NSString *const GHAPIEventV3TypeTeamAddEvent;
extern NSString *const GHAPIEventV3TypeWatchEvent;

typedef enum {
    GHAPIEventTypeV3CommitComment = 0,
    GHAPIEventTypeV3CreateEvent,
    GHAPIEventTypeV3DeleteEvent,
    GHAPIEventTypeV3DownloadEvent,
    GHAPIEventTypeV3FollowEvent,
    GHAPIEventTypeV3ForkEvent,
    GHAPIEventTypeV3ForkApplyEvent,
    GHAPIEventTypeV3GistEvent,
    GHAPIEventTypeV3GollumEvent,
    GHAPIEventTypeV3IssueCommentEvent,
    GHAPIEventTypeV3IssuesEvent,
    GHAPIEventTypeV3MemberEvent,
    GHAPIEventTypeV3PublicEvent,
    GHAPIEventTypeV3PullRequestEvent,
    GHAPIEventTypeV3PushEvent,
    GHAPIEventTypeV3TeamAddEvent,
    GHAPIEventTypeV3WatchEvent,
} GHAPIEventTypeV3;


/**
 @class     GHAPIEventV3
 @abstract  represents an Event
 */
@interface GHAPIEventV3 : NSObject <NSCoding> {
@private
    GHAPIRepositoryV3 *_repository;
    GHAPIUserV3 *_actor;
    GHAPIOrganizationV3 *_organization;
    
    NSString *_createdAtString;
    NSString *_typeString;
    NSNumber *_public;
    
    GHAPIEventTypeV3 _type;
}

@property (nonatomic, readonly) GHAPIRepositoryV3 *repository;
@property (nonatomic, readonly) GHAPIUserV3 *actor;
@property (nonatomic, readonly) GHAPIOrganizationV3 *organization;
@property (nonatomic, readonly) NSString *createdAtString;
@property (nonatomic, readonly) NSString *typeString;
@property (nonatomic, readonly) NSNumber *public;

@property (nonatomic, readonly) GHAPIEventTypeV3 type;

- (id)initWithRawDictionary:(NSDictionary *)rawDictionary;

@end
