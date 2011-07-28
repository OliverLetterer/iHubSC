//
//  GHCreateEventPayload.h
//  iGithub
//
//  Created by Oliver Letterer on 02.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GHPayload.h"

typedef enum {
    GHCreateEventObjectUnknown = 0,
    GHCreateEventObjectRepository,
    GHCreateEventObjectBranch,
    GHCreateEventObjectTag
} GHCreateEventObject;

// :user created/deleted repository/branch/tag
@interface GHCreateEventPayload : GHPayload {
    NSString *_description;
    NSString *_masterBranch;
    NSString *_ref;
    NSString *_refType;
}

@property (nonatomic, copy) NSString *description;
@property (nonatomic, copy) NSString *masterBranch;
@property (nonatomic, copy) NSString *ref;
@property (nonatomic, copy) NSString *refType;

@property (nonatomic, readonly) GHCreateEventObject objectType;

@end
