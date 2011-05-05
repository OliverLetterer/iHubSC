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
    if ((self = [super initWithRawDictionary:rawDictionary])) {
        DLog(@"%@", rawDictionary);
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

@end
