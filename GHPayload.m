//
//  GHPayload.m
//  iGithub
//
//  Created by Oliver Letterer on 01.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHPayload.h"
#import "GithubAPI.h"

@implementation GHPayload

#pragma mark - setters and getters

- (GHPayloadEvent)type {
    return GHPayloadNoEvent;
}

#pragma mark - Initialization

- (id)initWithRawDictionary:(NSDictionary *)rawDictionary {
    rawDictionary = NSObjectExpectedClass(rawDictionary, NSDictionary.class);
    if ((self = [super init])) {
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
    if (self = [super init]) {
        
    }
    return self;
}


@end
