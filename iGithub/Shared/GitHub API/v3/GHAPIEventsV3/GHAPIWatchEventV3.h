//
//  GHAPIWatchEventV3.h
//  iGithub
//
//  Created by Oliver Letterer on 02.11.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHAPIEventV3.h"
#warning NSCoding



/**
 @class     GHAPIWatchEventV3
 @abstract  The event’s actor is the watcher, and the event’s repo is the watched repository.
 */
@interface GHAPIWatchEventV3 : GHAPIEventV3 {
@private
    NSString *_action;
}

@property (nonatomic, readonly) NSString *action;

@end
