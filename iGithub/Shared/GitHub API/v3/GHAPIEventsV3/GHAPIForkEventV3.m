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

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)encoder 
{
    [super encodeWithCoder:encoder];
    [encoder encodeObject:_forkedRepository forKey:@"customForkedRepository"];
}

- (id)initWithCoder:(NSCoder *)decoder 
{
    if ((self = [super initWithCoder:decoder])) {
        _forkedRepository = [decoder decodeObjectForKey:@"customForkedRepository"];
    }
    return self;
}

@end
