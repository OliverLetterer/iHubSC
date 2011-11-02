//
//  GHAPIMemberEventEventV3.h
//  iGithub
//
//  Created by Oliver Letterer on 02.11.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHAPIEventV3.h"
#import "GHAPIUserV3.h"



/**
 @class     GHAPIMemberEventEventV3
 @abstract  Triggered when a user is added as a collaborator to a repository.
 */
@interface GHAPIMemberEventV3 : GHAPIEventV3 <NSCoding> {
@private
    NSString *_action;
    GHAPIUserV3 *_member;
}

@property (nonatomic, readonly) NSString *action;
@property (nonatomic, readonly) GHAPIUserV3 *member;

@end
