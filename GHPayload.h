//
//  GHPayload.h
//  iGithub
//
//  Created by Oliver Letterer on 01.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    GHPayloadTypeNone = 0,
    GHPayloadTypeIssue,
    GHPayloadTypePush,
    GHPayloadTypePullRequest
} GHPayloadType;

@interface GHPayload : NSObject {
    NSString *_actor;
    NSString *_repo;
    NSString *_gravatarID;
}

@property (nonatomic, readonly) GHPayloadType type;

@property (nonatomic, copy) NSString *actor;
@property (nonatomic, copy) NSString *repo;
@property (nonatomic, copy) NSString *gravatarID;

- (id)initWithRawDictionary:(NSDictionary *)rawDictionary;

@end
