//
//  GHAPIGistFileV3.m
//  iGithub
//
//  Created by Oliver Letterer on 03.05.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHAPIGistFileV3.h"
#import "GithubAPI.h"

@implementation GHAPIGistFileV3

@synthesize filename=_filename, size=_size, URL=_URL, content=_content;

#pragma mark - Initialization

- (id)initWithRawDictionary:(NSDictionary *)rawDictionary {
    rawDictionary = NSObjectExpectedClass(rawDictionary, NSDictionary.class);
    if ((self = [super init])) {
        // Initialization code
        self.filename = [rawDictionary objectForKeyOrNilOnNullObject:@"filename"];
        self.size = [rawDictionary objectForKeyOrNilOnNullObject:@"size"];
        self.URL = [rawDictionary objectForKeyOrNilOnNullObject:@"raw_url"];
        self.content = [rawDictionary objectForKeyOrNilOnNullObject:@"content"];
    }
    return self;
}

#pragma mark - Memory management

- (void)dealloc {
    [_filename release];
    [_size release];
    [_URL release];
    [_content release];
    [super dealloc];
}

#pragma mark - Keyed Archiving

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:_filename forKey:@"filename"];
    [encoder encodeObject:_size forKey:@"size"];
    [encoder encodeObject:_URL forKey:@"uRL"];
    [encoder encodeObject:_content forKey:@"content"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super init])) {
        _filename = [[decoder decodeObjectForKey:@"filename"] retain];
        _size = [[decoder decodeObjectForKey:@"size"] retain];
        _URL = [[decoder decodeObjectForKey:@"uRL"] retain];
        _content = [[decoder decodeObjectForKey:@"content"] retain];
    }
    return self;
}

@end
