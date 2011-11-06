//
//  GHAPINewEventsEventV3.h
//  iGithub
//
//  Created by Oliver Letterer on 04.11.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHAPIEventV3.h"



/**
 @class     GHAPINewEventsEventV3
 @abstract  <#abstract comment#>
 */
@interface GHAPINewEventsEventV3 : GHAPIEventV3 <NSCoding> {
@private
    NSNumber *_numberOfNewEvents;
}

@property (nonatomic, strong) NSNumber *numberOfNewEvents;

@end
