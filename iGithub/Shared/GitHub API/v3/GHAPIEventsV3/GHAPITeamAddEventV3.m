//
//  GHAPITeamAddEventV3.m
//  iGithub
//
//  Created by Oliver Letterer on 02.11.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GithubAPI.h"



@implementation GHAPITeamAddEventV3
@synthesize teamRepository=_teamRepository, team=_team, teamUser=_teamUser;

#pragma mark - Initialization

- (id)initWithRawDictionary:(NSDictionary *)rawDictionary 
{
    GHAPIObjectExpectedClass(&rawDictionary, NSDictionary.class);
    if (self = [super initWithRawDictionary:rawDictionary]) {
        // Initialization code
        _team = [[GHAPITeamV3 alloc] initWithRawDictionary:[rawDictionary objectForKeyOrNilOnNullObject:@"team"] ];
        _teamRepository = [[GHAPIRepositoryV3 alloc] initWithRawDictionary:[rawDictionary objectForKeyOrNilOnNullObject:@"repo"] ];
        _teamUser = [[GHAPIUserV3 alloc] initWithRawDictionary:[rawDictionary objectForKeyOrNilOnNullObject:@"user"] ];
    }
    return self;
}

@end
