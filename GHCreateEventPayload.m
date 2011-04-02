//
//  GHCreateEventPayload.m
//  iGithub
//
//  Created by Oliver Letterer on 02.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHCreateEventPayload.h"


@implementation GHCreateEventPayload

@synthesize name=_name, object=_object, objectName=_objectName;

- (GHPayloadEvent)type {
    return GHPayloadCreateEvent;
}

- (GHCreateEventObject)objectType {
    if ([self.object isEqualToString:@"repository"]) {
        return GHCreateEventObjectRepository;
    } else if ([self.object isEqualToString:@"branch"]) {
        return GHCreateEventObjectBranch;
    }
    
    return GHCreateEventObjectUnknown;
}

#pragma mark - Initialization

- (id)initWithRawDictionary:(NSDictionary *)rawDictionary {
    if ((self = [super initWithRawDictionary:rawDictionary])) {
        // Initialization code
        self.name = [rawDictionary objectForKey:@"name"];
        self.object = [rawDictionary objectForKey:@"object"];
        self.objectName = [rawDictionary objectForKey:@"object_name"];
    }
    return self;
}

#pragma mark - Memory management

- (void)dealloc {
    [_name release];
    [_object release];
    [_objectName release];
    [super dealloc];
}

@end
