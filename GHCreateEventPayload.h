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
    GHCreateEventObjectBranch
} GHCreateEventObject;

@interface GHCreateEventPayload : GHPayload {
    NSString *_name;
    NSString *_object;
    NSString *_objectName;
}

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *object;
@property (nonatomic, copy) NSString *objectName;

@property (nonatomic, readonly) GHCreateEventObject objectType;

@end
