//
//  GHAPIForkApplyEventEventV3.m
//  iGithub
//
//  Created by Oliver Letterer on 02.11.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GithubAPI.h"



@implementation GHAPIForkApplyEventV3
@synthesize head=_head, before=_before, after=_after;

#pragma mark - Initialization

- (id)initWithRawDictionary:(NSDictionary *)rawDictionary 
{
    GHAPIObjectExpectedClass(&rawDictionary, NSDictionary.class);
    if (self = [super initWithRawDictionary:rawDictionary]) {
        // Initialization code
        _head = [rawDictionary objectForKeyOrNilOnNullObject:@"head"];
        _before = [rawDictionary objectForKeyOrNilOnNullObject:@"before"];
        _after = [rawDictionary objectForKeyOrNilOnNullObject:@"after"];
    }
    return self;
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)encoder 
{
    [super encodeWithCoder:encoder];
    [encoder encodeObject:_head forKey:@"customHead"];
    [encoder encodeObject:_before forKey:@"customBefore"];
    [encoder encodeObject:_after forKey:@"customAfter"];
}

- (id)initWithCoder:(NSCoder *)decoder 
{
    if ((self = [super initWithCoder:decoder])) {
        _head = [decoder decodeObjectForKey:@"customHead"];
        _before = [decoder decodeObjectForKey:@"customBefore"];
        _after = [decoder decodeObjectForKey:@"customAfter"];
    }
    return self;
}

@end
