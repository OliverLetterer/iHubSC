//
//  GHGollumEventPayload.h
//  iGithub
//
//  Created by Oliver Letterer on 03.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GHPayloadWithRepository.h"

// :user created/deleted :pageName in Wiki
@interface GHGollumEventPayload : GHPayload {
    NSArray *_events;
}

@property (nonatomic, strong) NSArray *events; // contains GHGollumPageEvent

@end
