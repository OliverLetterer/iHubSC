//
//  GHAPIGistEventEventV3.h
//  iGithub
//
//  Created by Oliver Letterer on 02.11.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHAPIEventV3.h"
#import "GHAPIGistV3.h"



/**
 @class     GHAPIGistEventEventV3
 @abstract  Gist got created or updated.
 */
@interface GHAPIGistEventV3 : GHAPIEventV3 <NSCoding> {
@private
    NSString *_action;
    GHAPIGistV3 *_gist;
}

@property (nonatomic, readonly) NSString *action;
@property (nonatomic, readonly) GHAPIGistV3 *gist;

@end
