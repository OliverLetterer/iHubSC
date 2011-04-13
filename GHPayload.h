//
//  GHPayload.h
//  iGithub
//
//  Created by Oliver Letterer on 01.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    GHPayloadNoEvent = 0,
    GHPayloadIssuesEvent,
    GHPayloadPushEvent,
    GHPayloadPullRequestEvent,
    GHPayloadCommitCommentEvent,
    GHPayloadFollowEvent,
    GHPayloadWatchEvent,
    GHPayloadCreateEvent,
    GHPayloadForkEvent,
    GHPayloadDeleteEvent,
    GHPayloadGollumEvent,
    GHPayloadGistEvent,
    GHPayloadDownloadEvent,
    GHPayloadMemberEvent,
    GHPayloadIssueCommentEvent,
    GHPayloadForkApplyEvent,
    GHPayloadPublicEvent
} GHPayloadEvent;

@interface GHPayload : NSObject {
    
}

@property (nonatomic, readonly) GHPayloadEvent type;

- (id)initWithRawDictionary:(NSDictionary *)rawDictionary;

@end
