//
//  GHPublicEventPayload.m
//  iGithub
//
//  Created by Oliver Letterer on 13.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHPublicEventPayload.h"
#import "GithubAPI.h"

@implementation GHPublicEventPayload

- (GHPayloadEvent)type {
    return GHPayloadPublicEvent;
}

#pragma mark - Initialization

- (id)initWithRawDictionary:(NSDictionary *)rawDictionary {
    rawDictionary = NSObjectExpectedClass(rawDictionary, NSDictionary.class);
    if ((self = [super initWithRawDictionary:rawDictionary])) {
        // Initialization code
    }
    return self;
}

#pragma mark - Memory management

- (void)dealloc {
    
    [super dealloc];
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder {
        [super encodeWithCoder:aCoder];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
            
    }
    return self;
}

@end
