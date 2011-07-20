//
//  GHDeleteEventPayload.m
//  iGithub
//
//  Created by Oliver Letterer on 03.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHDeleteEventPayload.h"
#import "GithubAPI.h"

@implementation GHDeleteEventPayload

@synthesize ref=_ref, refType=_refType;

- (GHPayloadEvent)type {
    return GHPayloadDeleteEvent;
}

#pragma mark - Initialization

- (id)initWithRawDictionary:(NSDictionary *)rawDictionary {
    if ((self = [super initWithRawDictionary:rawDictionary])) {
        // Initialization code
        self.ref = [rawDictionary objectForKeyOrNilOnNullObject:@"ref"];
        self.refType = [rawDictionary objectForKeyOrNilOnNullObject:@"ref_type"];
    }
    return self;
}

#pragma mark - Memory management

- (void)dealloc {
    [_ref release];
    [_refType release];
    [super dealloc];
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.ref forKey:@"ref"];
    [aCoder encodeObject:self.refType forKey:@"refType"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        self.ref = [aDecoder decodeObjectForKey:@"ref"];
        self.refType = [aDecoder decodeObjectForKey:@"refType"];
    }
    return self;
}

@end
