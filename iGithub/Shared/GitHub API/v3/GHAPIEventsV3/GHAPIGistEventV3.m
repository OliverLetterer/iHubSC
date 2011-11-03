//
//  GHAPIGistEventEventV3.m
//  iGithub
//
//  Created by Oliver Letterer on 02.11.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GithubAPI.h"



@implementation GHAPIGistEventV3
@synthesize action=_action, gist=_gist;

#pragma mark - Initialization

- (id)initWithRawPayloadDictionary:(NSDictionary *)rawDictionary 
{
    GHAPIObjectExpectedClass(&rawDictionary, NSDictionary.class);
    if (self = [super initWithRawPayloadDictionary:rawDictionary]) {
        // Initialization code
        _action = [rawDictionary objectForKeyOrNilOnNullObject:@"action"];
        _gist = [[GHAPIGistV3 alloc] initWithRawDictionary:[rawDictionary objectForKeyOrNilOnNullObject:@"gist"] ];
    }
    return self;
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)encoder 
{
    [super encodeWithCoder:encoder];
    [encoder encodeObject:_action forKey:@"customAction"];
    [encoder encodeObject:_gist forKey:@"customGist"];
}

- (id)initWithCoder:(NSCoder *)decoder 
{
    if ((self = [super initWithCoder:decoder])) {
        _action = [decoder decodeObjectForKey:@"customAction"];
        _gist = [decoder decodeObjectForKey:@"customGist"];
    }
    return self;
}

@end
