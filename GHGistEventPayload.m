//
//  GHGistEventPayload.m
//  iGithub
//
//  Created by Oliver Letterer on 03.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHGistEventPayload.h"
#import "GithubAPI.h"


@implementation GHGistEventPayload

@synthesize action=_action, descriptionGist=_descriptionGist, name=_name, snippet=_snippet, URL=_URL, gistID=_gistID;

- (GHPayloadEvent)type {
    return GHPayloadGistEvent;
}

#pragma mark - Initialization

- (id)initWithRawDictionary:(NSDictionary *)rawDictionary {
    rawDictionary = NSObjectExpectedClass(rawDictionary, NSDictionary.class);
    if ((self = [super initWithRawDictionary:rawDictionary])) {
        // Initialization code
        self.action = [rawDictionary objectForKeyOrNilOnNullObject:@"action"];
        self.descriptionGist = [rawDictionary objectForKeyOrNilOnNullObject:@"desc"];
        self.name = [rawDictionary objectForKeyOrNilOnNullObject:@"name"];
        self.snippet = [rawDictionary objectForKeyOrNilOnNullObject:@"snippet"];
        self.URL = [rawDictionary objectForKeyOrNilOnNullObject:@"url"];
        self.gistID = [[self.name componentsSeparatedByString:@": "] lastObject];
    }
    return self;
}

#pragma mark - Memory management

- (void)dealloc {
    [_action release];
    [_descriptionGist release];
    [_name release];
    [_snippet release];
    [_URL release];
    [_gistID release];
    
    [super dealloc];
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.action forKey:@"action"];
    [aCoder encodeObject:self.descriptionGist forKey:@"descriptionGist"];
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.snippet forKey:@"snippet"];
    [aCoder encodeObject:self.URL forKey:@"URL"];
    [aCoder encodeObject:self.gistID forKey:@"gistID"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        self.action = [aDecoder decodeObjectForKey:@"action"];
        self.descriptionGist = [aDecoder decodeObjectForKey:@"descriptionGist"];
        self.name = [aDecoder decodeObjectForKey:@"name"];
        self.snippet = [aDecoder decodeObjectForKey:@"snippet"];
        self.URL = [aDecoder decodeObjectForKey:@"URL"];
        self.gistID = [aDecoder decodeObjectForKey:@"gistID"];
    }
    return self;
}

@end
