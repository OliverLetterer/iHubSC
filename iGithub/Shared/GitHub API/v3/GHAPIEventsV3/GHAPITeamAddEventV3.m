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

- (id)initWithRawPayloadDictionary:(NSDictionary *)rawDictionary 
{
    GHAPIObjectExpectedClass(&rawDictionary, NSDictionary.class);
    if (self = [super initWithRawPayloadDictionary:rawDictionary]) {
        // Initialization code
        _team = [[GHAPITeamV3 alloc] initWithRawDictionary:[rawDictionary objectForKeyOrNilOnNullObject:@"team"] ];
        _teamRepository = [[GHAPIRepositoryV3 alloc] initWithRawDictionary:[rawDictionary objectForKeyOrNilOnNullObject:@"repo"] ];
        _teamUser = [[GHAPIUserV3 alloc] initWithRawDictionary:[rawDictionary objectForKeyOrNilOnNullObject:@"user"] ];
    }
    return self;
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)encoder 
{
    [super encodeWithCoder:encoder];
    [encoder encodeObject:_teamRepository forKey:@"teamRepository"];
    [encoder encodeObject:_team forKey:@"team"];
    [encoder encodeObject:_teamUser forKey:@"teamUser"];
}

- (id)initWithCoder:(NSCoder *)decoder 
{
    if ((self = [super initWithCoder:decoder])) {
        _teamRepository = [decoder decodeObjectForKey:@"teamRepository"];
        _team = [decoder decodeObjectForKey:@"team"];
        _teamUser = [decoder decodeObjectForKey:@"teamUser"];
    }
    return self;
}

@end
