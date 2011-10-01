//
//  GHGollumEventPayload.m
//  iGithub
//
//  Created by Oliver Letterer on 03.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHGollumEventPayload.h"
#import "GithubAPI.h"

@implementation GHGollumEventPayload
@synthesize events=_events;

- (GHPayloadEvent)type {
    return GHPayloadGollumEvent;
}

#pragma mark - Initialization

- (id)initWithRawDictionary:(NSDictionary *)rawDictionary {
    GHAPIObjectExpectedClass(&rawDictionary, NSDictionary.class);
    if ((self = [super initWithRawDictionary:rawDictionary])) {
        // Initialization code
        NSArray *pages = [rawDictionary objectForKeyOrNilOnNullObject:@"pages"];
        GHAPIObjectExpectedClass(&pages, NSArray.class);
        NSMutableArray *events = [NSMutableArray arrayWithCapacity:pages.count];
        
        for (NSDictionary *rawEventDictionary in pages) {
            GHGollumPageEvent *event = [[GHGollumPageEvent alloc] initWithRawDictionary:rawEventDictionary];
            [events addObject:event];
        }
        
        _events = events;
    }
    return self;
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:_events forKey:@"events"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        _events = [aDecoder decodeObjectForKey:@"events"];
    }
    return self;
}

@end
