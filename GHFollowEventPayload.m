//
//  GHFollowEventPayload.m
//  iGithub
//
//  Created by Oliver Letterer on 02.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHFollowEventPayload.h"


@implementation GHFollowEventPayload

@synthesize target=_target;

- (GHPayloadEvent)type {
    return GHPayloadFollowEvent;
}

#pragma mark - Initialization

- (id)initWithRawDictionary:(NSDictionary *)rawDictionary {
    if ((self = [super initWithRawDictionary:rawDictionary])) {
        // Initialization code
        self.target = [[[GHTarget alloc] initWithRawDictionary:[rawDictionary objectForKey:@"target"]] autorelease];
    }
    return self;
}

#pragma mark - Memory management

- (void)dealloc {
    [_target release];
    [super dealloc];
}

@end
