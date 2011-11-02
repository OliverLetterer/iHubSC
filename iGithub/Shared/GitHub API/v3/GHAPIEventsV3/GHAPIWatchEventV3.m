//
//  GHAPIWatchEventV3.m
//  iGithub
//
//  Created by Oliver Letterer on 02.11.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GithubAPI.h"



@implementation GHAPIWatchEventV3
@synthesize action=_action;

#pragma mark - Initialization

- (id)initWithRawDictionary:(NSDictionary *)rawDictionary 
{
    GHAPIObjectExpectedClass(&rawDictionary, NSDictionary.class);
    if (self = [super initWithRawDictionary:rawDictionary]) {
        // Initialization code
        _action = [rawDictionary objectForKeyOrNilOnNullObject:@"action"];
    }
    return self;
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)encoder 
{
    [super encodeWithCoder:encoder];
    [encoder encodeObject:_action forKey:@"action"];
}

- (id)initWithCoder:(NSCoder *)decoder 
{
    if ((self = [super initWithCoder:decoder])) {
        _action = [decoder decodeObjectForKey:@"action"];
    }
    return self;
}

@end
