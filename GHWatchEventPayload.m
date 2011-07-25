//
//  GHWatchEventPayload.m
//  iGithub
//
//  Created by Oliver Letterer on 02.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHWatchEventPayload.h"
#import "GithubAPI.h"

@implementation GHWatchEventPayload

@synthesize action=_action;

- (GHPayloadEvent)type {
    return GHPayloadWatchEvent;
}

#pragma mark - Initialization

- (id)initWithRawDictionary:(NSDictionary *)rawDictionary {
    rawDictionary = NSObjectExpectedClass(rawDictionary, NSDictionary.class);
    if ((self = [super initWithRawDictionary:rawDictionary])) {
        // Initialization code
        self.action = [rawDictionary objectForKeyOrNilOnNullObject:@"action"];
    }
    return self;
}

#pragma mark - Memory management

- (void)dealloc {
    [_action release];
    [super dealloc];
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.action forKey:@"action"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        self.action = [aDecoder decodeObjectForKey:@"action"];
    }
    return self;
}

@end
