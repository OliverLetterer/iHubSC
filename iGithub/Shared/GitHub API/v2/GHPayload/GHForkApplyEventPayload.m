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

@synthesize before=_before, head=_head, after=_after;

- (GHPayloadEvent)type {
    return GHPayloadForkApplyEvent;
}

#pragma mark - Initialization

- (id)initWithRawDictionary:(NSDictionary *)rawDictionary {
    rawDictionary = GHAPIObjectExpectedClass(rawDictionary, NSDictionary.class);
    if ((self = [super initWithRawDictionary:rawDictionary])) {
        // Initialization code
        self.before = [rawDictionary objectForKeyOrNilOnNullObject:@"before"];
        self.head = [rawDictionary objectForKeyOrNilOnNullObject:@"head"];
        self.after = [rawDictionary objectForKeyOrNilOnNullObject:@"after"];
    }
    return self;
}

#pragma mark - Memory management


#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.before forKey:@"before"];
    [aCoder encodeObject:self.head forKey:@"head"];
    [aCoder encodeObject:self.after forKey:@"after"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        self.before = [aDecoder decodeObjectForKey:@"before"];
        self.head = [aDecoder decodeObjectForKey:@"head"];
        self.after = [aDecoder decodeObjectForKey:@"after"];
    }
    return self;
}

@end
