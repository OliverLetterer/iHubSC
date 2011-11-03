//
//  GHAPIDeleteEventEventV3.m
//  iGithub
//
//  Created by Oliver Letterer on 02.11.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GithubAPI.h"



@implementation GHAPIDeleteEventV3
@synthesize objectType=_objectType, objectName=_objectName;

#pragma mark - Initialization

- (id)initWithRawPayloadDictionary:(NSDictionary *)rawDictionary 
{
    GHAPIObjectExpectedClass(&rawDictionary, NSDictionary.class);
    if (self = [super initWithRawPayloadDictionary:rawDictionary]) {
        // Initialization code
        _objectType = [rawDictionary objectForKeyOrNilOnNullObject:@"ref_type"];
        _objectName = [rawDictionary objectForKeyOrNilOnNullObject:@"ref"];
    }
    return self;
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)encoder 
{
    [super encodeWithCoder:encoder];
    [encoder encodeObject:_objectType forKey:@"customObjectType"];
    [encoder encodeObject:_objectName forKey:@"customObjectName"];
}

- (id)initWithCoder:(NSCoder *)decoder 
{
    if ((self = [super initWithCoder:decoder])) {
        _objectType = [decoder decodeObjectForKey:@"customObjectType"];
        _objectName = [decoder decodeObjectForKey:@"customObjectName"];
    }
    return self;
}

@end
