//
//  GHDeleteEventPayload.h
//  iGithub
//
//  Created by Oliver Letterer on 03.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GHPayload.h"

// :user deleted :refType
@interface GHDeleteEventPayload : GHPayload {
    NSString *_ref;
    NSString *_refType;
}

@property (nonatomic, copy) NSString *ref;
@property (nonatomic, copy) NSString *refType;

@end
