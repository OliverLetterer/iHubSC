//
//  GHAPIGollumEventEventV3.h
//  iGithub
//
//  Created by Oliver Letterer on 02.11.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHAPIEventV3.h"



/**
 @class     GHAPIGollumEventEventV3
 @abstract  Wiki pages got updated.
 */
@interface GHAPIGollumEventV3 : GHAPIEventV3 <NSCoding> {
@private
    NSArray *_pages;
}

@property (nonatomic, readonly) NSArray *pages;

@end
