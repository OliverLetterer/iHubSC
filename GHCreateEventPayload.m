//
//  GHCreateEventPayload.m
//  iGithub
//
//  Created by Oliver Letterer on 02.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHCreateEventPayload.h"
#import "GithubAPI.h"

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
    } else if ([self.object isEqualToString:@"tag"]) {
        return GHCreateEventObjectTag;
    }
    
    return GHCreateEventObjectUnknown;
}

#pragma mark - Initialization

- (id)initWithRawDictionary:(NSDictionary *)rawDictionary {
    if ((self = [super initWithRawDictionary:rawDictionary])) {
        // Initialization code
        self.name = [rawDictionary objectForKeyOrNilOnNullObject:@"name"];
        self.object = [rawDictionary objectForKeyOrNilOnNullObject:@"object"];
        self.objectName = [rawDictionary objectForKeyOrNilOnNullObject:@"object_name"];
        
        if (self.objectType == GHCreateEventObjectUnknown) {
            DLog(@"%@", rawDictionary);
            DLog(@"Detected Unkonw Create Event");
        }
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
