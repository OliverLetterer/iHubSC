//
//  GHAPIFollowEventEventV3.h
//  iGithub
//
//  Created by Oliver Letterer on 02.11.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHAPIEventV3.h"
#import "GHAPIUserV3.h"



/**
 @class     GHAPIFollowEventEventV3
 @abstract  The user that was just followed.
 */
@interface GHAPIFollowEventV3 : GHAPIEventV3 <NSCoding> {
@private
    GHAPIUserV3 *_user;
}

@property (nonatomic, readonly) GHAPIUserV3 *user;

@end
