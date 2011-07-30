//
//  GHAPITreeFileV3.m
//  iGithub
//
//  Created by Oliver Letterer on 30.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHAPITreeFileV3.h"
#import "GithubAPI.h"

@implementation GHAPITreeFileV3
@synthesize path=_path, mode=_mode, type=_type, size=_size, SHA=_SHA, URL=_URL;

#pragma mark - Initialization

- (id)initWithRawDictionary:(NSDictionary *)rawDictionary {
    rawDictionary=GHAPIObjectExpectedClass(rawDictionary, NSDictionary.class);
    if ((self = [super init])) {
        // Initialization code
        self.path = [rawDictionary objectForKeyOrNilOnNullObject:@"path"];
        self.mode = [rawDictionary objectForKeyOrNilOnNullObject:@"mode"];
        self.type = [rawDictionary objectForKeyOrNilOnNullObject:@"type"];
        self.size = [rawDictionary objectForKeyOrNilOnNullObject:@"size"];
        self.SHA = [rawDictionary objectForKeyOrNilOnNullObject:@"sha"];
        self.URL = [rawDictionary objectForKeyOrNilOnNullObject:@"url"];
    }
    return self;
}

#pragma mark - Keyed Archiving

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.path forKey:@"path"];
    [encoder encodeObject:self.mode forKey:@"mode"];
    [encoder encodeObject:self.type forKey:@"type"];
    [encoder encodeObject:self.size forKey:@"size"];
    [encoder encodeObject:self.SHA forKey:@"sHA"];
    [encoder encodeObject:self.URL forKey:@"uRL"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super init])) {
        self.path = [decoder decodeObjectForKey:@"path"];
        self.mode = [decoder decodeObjectForKey:@"mode"];
        self.type = [decoder decodeObjectForKey:@"type"];
        self.size = [decoder decodeObjectForKey:@"size"];
        self.SHA = [decoder decodeObjectForKey:@"sHA"];
        self.URL = [decoder decodeObjectForKey:@"uRL"];
    }
    return self;
}

@end
