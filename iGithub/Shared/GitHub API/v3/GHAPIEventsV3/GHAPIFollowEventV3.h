//
//  GHAPIFollowEventEventV3.h
//  iGithub
//
//  Created by Oliver Letterer on 02.11.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHAPIEventV3.h"
#import "GHAPIUserV3.h"
#warning NSCoding



/**
 @class     GHAPIFollowEventEventV3
 @abstract  The user that was just followed.
 */
@interface GHAPIFollowEventV3 : GHAPIEventV3 {
@private
    GHAPIUserV3 *_user;
}

@property (nonatomic, readonly) GHAPIUserV3 *user;

@end
