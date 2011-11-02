//
//  GHAPIDeleteEventEventV3.h
//  iGithub
//
//  Created by Oliver Letterer on 02.11.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHAPIEventV3.h"



/**
 @class     GHAPIDeleteEventEventV3
 @abstract  Represents a deleted branch or tag.
 */
@interface GHAPIDeleteEventV3 : GHAPIEventV3 <NSCoding> {
@private
    NSString *_objectType;
    NSString *_objectName;
}

@property (nonatomic, readonly) NSString *objectType;
@property (nonatomic, readonly) NSString *objectName;

@end
