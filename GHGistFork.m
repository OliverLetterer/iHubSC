//
//  GHGistFork.m
//  iGithub
//
//  Created by Oliver Letterer on 05.05.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHGistFork.h"
#import "GithubAPI.h"

@implementation GHGistFork

@synthesize user=_user, URL=_URL, createdAt=_createdAt;

#pragma mark - Initialization

- (id)initWithRawDictionary:(NSDictionary *)rawDictionay {
    if ((self = [super init])) {
        // Initialization code
        self.user = [[[GHUser alloc] initWithRawDictionary:[rawDictionay objectForKeyOrNilOnNullObject:@"user"] ] autorelease];
        self.URL = [rawDictionay objectForKeyOrNilOnNullObject:@"url"];
        self.createdAt = [rawDictionay objectForKeyOrNilOnNullObject:@"created_at"];
    }
    return self;
}

#pragma mark - Memory management

- (void)dealloc {
    [_user release];
    [_URL release];
    [_createdAt release];
    
    [super dealloc];
}

@end
