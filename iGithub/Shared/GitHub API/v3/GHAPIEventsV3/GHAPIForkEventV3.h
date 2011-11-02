//
//  GHAPIForkEventEventV3.h
//  iGithub
//
//  Created by Oliver Letterer on 02.11.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHAPIEventV3.h"
#import "GHAPIRepositoryV3.h"
#warning NSCoding



/**
 @class     GHAPIForkEventEventV3
 @abstract  Repository got forked.
 */
@interface GHAPIForkEventV3 : GHAPIEventV3 {
@private
    GHAPIRepositoryV3 *_forkedRepository;
}

@property (nonatomic, readonly) GHAPIRepositoryV3 *forkedRepository;

@end
