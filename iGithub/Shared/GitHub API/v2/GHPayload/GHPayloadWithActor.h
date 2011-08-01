//
//  GHPayloadWithActor.h
//  iGithub
//
//  Created by Oliver Letterer on 02.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GHPayload.h"

@interface GHPayloadWithActor : GHPayload {
    NSString *_actor;
    NSString *_gravatarID;
}

@property (nonatomic, copy) NSString *actor;
@property (nonatomic, copy) NSString *gravatarID;

@end
