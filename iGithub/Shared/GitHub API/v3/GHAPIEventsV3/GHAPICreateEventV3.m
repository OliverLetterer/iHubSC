//
//  GHAPICreateEventEventV3.m
//  iGithub
//
//  Created by Oliver Letterer on 02.11.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GithubAPI.h"



@implementation GHAPICreateEventV3
@synthesize createdObject=_createdObject, objectName=_objectName, masterBranch=_masterBranch, description=_description;

#pragma mark - Initialization

- (id)initWithRawPayloadDictionary:(NSDictionary *)rawDictionary 
{
    GHAPIObjectExpectedClass(&rawDictionary, NSDictionary.class);
    if (self = [super initWithRawPayloadDictionary:rawDictionary]) {
        // Initialization code
        _createdObject = [rawDictionary objectForKeyOrNilOnNullObject:@"ref_type"];
        _objectName = [rawDictionary objectForKeyOrNilOnNullObject:@"ref"];
        _masterBranch = [rawDictionary objectForKeyOrNilOnNullObject:@"master_branch"];
        _description = [rawDictionary objectForKeyOrNilOnNullObject:@"description"];
    }
    return self;
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)encoder 
{
    [super encodeWithCoder:encoder];
    [encoder encodeObject:_createdObject forKey:@"customCreatedObject"];
    [encoder encodeObject:_objectName forKey:@"customObjectName"];
    [encoder encodeObject:_masterBranch forKey:@"customMasterBranch"];
    [encoder encodeObject:_description forKey:@"customDescription"];
}

- (id)initWithCoder:(NSCoder *)decoder 
{
    if ((self = [super initWithCoder:decoder])) {
        _createdObject = [decoder decodeObjectForKey:@"customCreatedObject"];
        _objectName = [decoder decodeObjectForKey:@"customObjectName"];
        _masterBranch = [decoder decodeObjectForKey:@"customMasterBranch"];
        _description = [decoder decodeObjectForKey:@"customDescription"];
    }
    return self;
}

@end
