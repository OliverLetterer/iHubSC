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

- (id)initWithRawDictionary:(NSDictionary *)rawDictionary 
{
    GHAPIObjectExpectedClass(&rawDictionary, NSDictionary.class);
    if (self = [super initWithRawDictionary:rawDictionary]) {
        // Initialization code
        _objectType = [rawDictionary objectForKeyOrNilOnNullObject:@"ref_type"];
        _objectName = [rawDictionary objectForKeyOrNilOnNullObject:@"ref"];
    }
    return self;
}

@end
