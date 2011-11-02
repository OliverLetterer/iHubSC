//
//  GHAPITeamAddEventV3.h
//  iGithub
//
//  Created by Oliver Letterer on 02.11.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHAPIEventV3.h"
#import "GHAPITeamV3.h"
#import "GHAPIUserV3.h"
#import "GHAPIRepositoryV3.h"



/**
 @class     GHAPITeamAddEventV3
 @abstract  <#abstract comment#>
 */
@interface GHAPITeamAddEventV3 : GHAPIEventV3 <NSCoding> {
@private
    GHAPIRepositoryV3 *_teamRepository;
    GHAPITeamV3 *_team;
    GHAPIUserV3 *_teamUser;
}

@property (nonatomic, readonly) GHAPIRepositoryV3 *teamRepository;
@property (nonatomic, readonly) GHAPITeamV3 *team;
@property (nonatomic, readonly) GHAPIUserV3 *teamUser;

@end
