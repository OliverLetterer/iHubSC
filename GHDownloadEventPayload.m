//
//  GHDownloadEventPayload.m
//  iGithub
//
//  Created by Oliver Letterer on 03.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHDownloadEventPayload.h"
#import "GithubAPI.h"

@implementation GHDownloadEventPayload

@synthesize ID=_ID, URL=_URL;

- (GHPayloadEvent)type {
    return GHPayloadDownloadEvent;
}

#pragma mark - Initialization

- (id)initWithRawDictionary:(NSDictionary *)rawDictionary {
    if ((self = [super initWithRawDictionary:rawDictionary])) {
        // Initialization code
        self.ID = [rawDictionary objectForKeyOrNilOnNullObject:@"id"];
        self.URL = [rawDictionary objectForKeyOrNilOnNullObject:@"url"];
    }
    return self;
}

#pragma mark - Memory management

- (void)dealloc {
    [_ID release];
    [_URL release];
    [super dealloc];
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.ID forKey:@"ID"];
    [aCoder encodeObject:self.URL forKey:@"URL"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        self.ID = [aDecoder decodeObjectForKey:@"ID"];
        self.URL = [aDecoder decodeObjectForKey:@"URL"];
    }
    return self;
}

@end
