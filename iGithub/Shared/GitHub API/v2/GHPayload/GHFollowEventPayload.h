//
//  GHFollowEventPayload.h
//  iGithub
//
//  Created by Oliver Letterer on 02.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GHPayload.h"
#import "GHTarget.h"

// X started following Y
@interface GHFollowEventPayload : GHPayload {
    GHTarget *_target;
}

@property (nonatomic, retain) GHTarget *target;

@end
