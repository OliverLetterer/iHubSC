//
//  GHAPINewEventsEventV3.m
//  iGithub
//
//  Created by Oliver Letterer on 04.11.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GithubAPI.h"



@implementation GHAPINewEventsEventV3
@synthesize numberOfNewEvents=_numberOfNewEvents;

#pragma mark - Initialization

- (id)init
{
    if (self = [super init]) {
        // Initialization code
        _type = GHAPIEventTypeV3NewEvents;
    }
    return self;
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)encoder 
{
    [encoder encodeObject:_numberOfNewEvents forKey:@"numberOfNewEvents"];
}

- (id)initWithCoder:(NSCoder *)decoder 
{
    if ((self = [super init])) {
        _numberOfNewEvents = [decoder decodeObjectForKey:@"numberOfNewEvents"];
    }
    return self;
}

@end
