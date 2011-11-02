//
//  GHAPICreateEventEventV3.h
//  iGithub
//
//  Created by Oliver Letterer on 02.11.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHAPIEventV3.h"
#warning NSCoding


/**
 @class     GHAPICreateEventEventV3
 @abstract  Represents a created repository, branch, or tag.
 */
@interface GHAPICreateEventV3 : GHAPIEventV3 {
@private
    NSString *_createdObject;
    NSString *_objectName;
    NSString *_masterBranch;
    NSString *_description;
}

@property (nonatomic, readonly) NSString *createdObject;
@property (nonatomic, readonly) NSString *objectName;
@property (nonatomic, readonly) NSString *masterBranch;
@property (nonatomic, readonly) NSString *description;

@end
