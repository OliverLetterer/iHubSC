//
//  GHAPIGistCommentV3.m
//  iGithub
//
//  Created by Oliver Letterer on 05.05.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHAPIGistCommentV3.h"
#import "GithubAPI.h"

@implementation GHAPIGistCommentV3

@synthesize ID=_ID, URL=_URL, body=_body, user=_user, createdAt=_createdAt;

#pragma mark - Initialization

- (id)initWithRawDictionary:(NSDictionary *)rawDictionay {
    if ((self = [super init])) {
        // Initialization code
        self.ID = [rawDictionay objectForKeyOrNilOnNullObject:@"id"];
        self.URL = [rawDictionay objectForKeyOrNilOnNullObject:@"url"];
        self.body = [rawDictionay objectForKeyOrNilOnNullObject:@"body"];
        self.createdAt = [rawDictionay objectForKeyOrNilOnNullObject:@"created_at"];
        
        self.user = [[[GHAPIUserV3 alloc] initWithRawDictionary:[rawDictionay objectForKeyOrNilOnNullObject:@"user"] ] autorelease];
    }
    return self;
}

#pragma mark - Memory management

- (void)dealloc {
    [_ID release];
    [_URL release];
    [_body release];
    [_user release];
    [_createdAt release];
    [super dealloc];
}

#pragma mark Keyed Archiving

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:_ID forKey:@"iD"];
    [encoder encodeObject:_URL forKey:@"uRL"];
    [encoder encodeObject:_body forKey:@"body"];
    [encoder encodeObject:_user forKey:@"user"];
    [encoder encodeObject:_createdAt forKey:@"createdAt"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super init])) {
        _ID = [[decoder decodeObjectForKey:@"iD"] retain];
        _URL = [[decoder decodeObjectForKey:@"uRL"] retain];
        _body = [[decoder decodeObjectForKey:@"body"] retain];
        _user = [[decoder decodeObjectForKey:@"user"] retain];
        _createdAt = [[decoder decodeObjectForKey:@"createdAt"] retain];
    }
    return self;
}

@end
