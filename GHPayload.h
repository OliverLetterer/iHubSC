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
    GHPayloadWatchEvent
} GHPayloadEvent;

@interface GHPayload : NSObject {
    NSString *_actor;
    NSString *_gravatarID;
}

@property (nonatomic, readonly) GHPayloadEvent type;

@property (nonatomic, copy) NSString *actor;
@property (nonatomic, copy) NSString *gravatarID;

- (id)initWithRawDictionary:(NSDictionary *)rawDictionary;

@end
