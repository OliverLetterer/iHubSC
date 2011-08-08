//
//  GHFollowEventPayload.m
//  iGithub
//
//  Created by Oliver Letterer on 02.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHFollowEventPayload.h"
#import "GithubAPI.h"

@implementation GHFollowEventPayload

@synthesize target=_target;

- (GHPayloadEvent)type {
    return GHPayloadFollowEvent;
}

#pragma mark - Initialization

- (id)initWithRawDictionary:(NSDictionary *)rawDictionary {
    GHAPIObjectExpectedClass(&rawDictionary, NSDictionary.class);
    if ((self = [super initWithRawDictionary:rawDictionary])) {
        // Initialization code
        id targetDictionary = [rawDictionary objectForKeyOrNilOnNullObject:@"target"];
        id targetAttributes = [rawDictionary objectForKeyOrNilOnNullObject:@"target_attributes"];
        if ([[targetDictionary class] isSubclassOfClass:[NSDictionary class] ]) {
            self.target = [[GHTarget alloc] initWithRawDictionary:targetDictionary];
        } else if ([[targetAttributes class] isSubclassOfClass:[NSDictionary class] ]) {
            self.target = [[GHTarget alloc] initWithRawDictionary:targetAttributes];
        }
    }
    return self;
}

#pragma mark - Memory management


#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.target forKey:@"target"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        self.target = [aDecoder decodeObjectForKey:@"target"];
    }
    return self;
}

@end
