//
//  GHPublicEventPayload.m
//  iGithub
//
//  Created by Oliver Letterer on 13.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHPublicEventPayload.h"


@implementation GHPublicEventPayload

- (GHPayloadEvent)type {
    return GHPayloadPublicEvent;
}

#pragma mark - Initialization

- (id)initWithRawDictionary:(NSDictionary *)rawDictionary {
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
        
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
            
    }
    return self;
}

@end
