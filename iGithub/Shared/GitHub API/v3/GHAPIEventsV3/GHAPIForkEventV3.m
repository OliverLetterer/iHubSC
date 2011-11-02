//
//  GHAPIForkEventEventV3.m
//  iGithub
//
//  Created by Oliver Letterer on 02.11.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GithubAPI.h"



@implementation GHAPIForkEventV3
@synthesize forkedRepository=_forkedRepository;

#pragma mark - Initialization

- (id)initWithRawDictionary:(NSDictionary *)rawDictionary 
{
    GHAPIObjectExpectedClass(&rawDictionary, NSDictionary.class);
    if (self = [super initWithRawDictionary:rawDictionary]) {
        // Initialization code
        _forkedRepository = [[GHAPIRepositoryV3 alloc] initWithRawDictionary:[rawDictionary objectForKeyOrNilOnNullObject:@"forkee"] ];
    }
    return self;
}

@end
