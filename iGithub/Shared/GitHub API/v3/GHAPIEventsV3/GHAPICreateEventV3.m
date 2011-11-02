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

- (id)initWithRawDictionary:(NSDictionary *)rawDictionary 
{
    GHAPIObjectExpectedClass(&rawDictionary, NSDictionary.class);
    if (self = [super initWithRawDictionary:rawDictionary]) {
        // Initialization code
        _createdObject = [rawDictionary objectForKeyOrNilOnNullObject:@"ref_type"];
        _objectName = [rawDictionary objectForKeyOrNilOnNullObject:@"ref"];
        _masterBranch = [rawDictionary objectForKeyOrNilOnNullObject:@"master_branch"];
        _description = [rawDictionary objectForKeyOrNilOnNullObject:@"description"];
    }
    return self;
}

@end
