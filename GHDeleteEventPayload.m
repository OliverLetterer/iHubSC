//
//  GHDeleteEventPayload.m
//  iGithub
//
//  Created by Oliver Letterer on 03.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHDeleteEventPayload.h"


@implementation GHDeleteEventPayload

@synthesize ref=_ref, refType=_refType;

- (GHPayloadEvent)type {
    return GHPayloadDeleteEvent;
}

#pragma mark - Initialization

- (id)initWithRawDictionary:(NSDictionary *)rawDictionary {
    if ((self = [super initWithRawDictionary:rawDictionary])) {
        // Initialization code
        self.ref = [rawDictionary objectForKey:@"ref"];
        self.refType = [rawDictionary objectForKey:@"ref_type"];
    }
    return self;
}

#pragma mark - Memory management

- (void)dealloc {
    [_ref release];
    [_refType release];
    [super dealloc];
}

@end
