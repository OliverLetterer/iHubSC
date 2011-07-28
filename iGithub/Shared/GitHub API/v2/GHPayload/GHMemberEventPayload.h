//
//  GHMemberEventPayload.h
//  iGithub
//
//  Created by Oliver Letterer on 03.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GHPayloadWithRepository.h"

@class GHActorAttributes;

// when a user was added to a repository: "kabuki added to kabuki/escort-mission"
@interface GHMemberEventPayload : GHPayload {
    NSString *_action;
    GHActorAttributes *_member;
}

@property (nonatomic, copy) NSString *action;
@property (nonatomic, retain) GHActorAttributes *member;

@end
