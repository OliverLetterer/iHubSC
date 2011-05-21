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

- (id)initWithRawDictionary:(NSDictionary *)rawDictionay {
    if ((self = [super init])) {
        // Initialization code
        self.filename = [rawDictionay objectForKeyOrNilOnNullObject:@"filename"];
        self.size = [rawDictionay objectForKeyOrNilOnNullObject:@"size"];
        self.URL = [rawDictionay objectForKeyOrNilOnNullObject:@"raw_url"];
        self.content = [rawDictionay objectForKeyOrNilOnNullObject:@"content"];
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

@end
