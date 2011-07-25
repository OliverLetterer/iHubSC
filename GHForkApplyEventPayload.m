//
//  GHForkApplyEventPayload.m
//  iGithub
//
//  Created by Oliver Letterer on 12.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHForkApplyEventPayload.h"
#import "GithubAPI.h"

@implementation GHForkApplyEventPayload

@synthesize commit=_commit, head=_head, original=_original;

- (GHPayloadEvent)type {
    return GHPayloadForkApplyEvent;
}

#pragma mark - Initialization

- (id)initWithRawDictionary:(NSDictionary *)rawDictionary {
    rawDictionary = GHAPIObjectExpectedClass(rawDictionary, NSDictionary.class);
    if ((self = [super initWithRawDictionary:rawDictionary])) {
        // Initialization code
        self.commit = [rawDictionary objectForKeyOrNilOnNullObject:@"commit"];
        self.head = [rawDictionary objectForKeyOrNilOnNullObject:@"head"];
        self.original = [rawDictionary objectForKeyOrNilOnNullObject:@"original"];
    }
    return self;
}

#pragma mark - Memory management

- (void)dealloc {
    [_commit release];
    [_head release];
    [_original release];
    [super dealloc];
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.commit forKey:@"commit"];
    [aCoder encodeObject:self.head forKey:@"head"];
    [aCoder encodeObject:self.original forKey:@"original"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        self.commit = [aDecoder decodeObjectForKey:@"commit"];
        self.head = [aDecoder decodeObjectForKey:@"head"];
        self.original = [aDecoder decodeObjectForKey:@"original"];
    }
    return self;
}

@end
