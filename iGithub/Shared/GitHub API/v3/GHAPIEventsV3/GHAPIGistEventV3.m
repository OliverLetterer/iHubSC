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

- (id)initWithRawDictionary:(NSDictionary *)rawDictionary 
{
    GHAPIObjectExpectedClass(&rawDictionary, NSDictionary.class);
    if (self = [super initWithRawDictionary:rawDictionary]) {
        // Initialization code
        _action = [rawDictionary objectForKeyOrNilOnNullObject:@"action"];
        _gist = [[GHAPIGistV3 alloc] initWithRawDictionary:[rawDictionary objectForKeyOrNilOnNullObject:@"gist"] ];
    }
    return self;
}

@end
