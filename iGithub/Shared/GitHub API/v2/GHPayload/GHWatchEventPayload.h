//
//  GHWatchEventPayload.h
//  iGithub
//
//  Created by Oliver Letterer on 02.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GHPayloadWithRepository.h"

// :user started/stoped watching :repository
@interface GHWatchEventPayload : GHPayload {
    NSString *_action;
}

@property (nonatomic, copy) NSString *action;

@end
