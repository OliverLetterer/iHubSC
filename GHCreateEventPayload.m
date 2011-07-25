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

@synthesize description = _description, masterBranch = _masterBranch, ref = _ref, refType = _refType;

- (GHPayloadEvent)type {
    return GHPayloadCreateEvent;
}

- (GHCreateEventObject)objectType {
    if ([self.refType isEqualToString:@"repository"]) {
        return GHCreateEventObjectRepository;
    } else if ([self.refType isEqualToString:@"branch"]) {
        return GHCreateEventObjectBranch;
    } else if ([self.refType isEqualToString:@"tag"]) {
        return GHCreateEventObjectTag;
    }
    
    return GHCreateEventObjectUnknown;
}

#pragma mark - Initialization

- (id)initWithRawDictionary:(NSDictionary *)rawDictionary {
    rawDictionary = NSObjectExpectedClass(rawDictionary, NSDictionary.class);
    if ((self = [super initWithRawDictionary:rawDictionary])) {
        // Initialization code
        self.description = [rawDictionary objectForKeyOrNilOnNullObject:@"description"];
        self.masterBranch = [rawDictionary objectForKeyOrNilOnNullObject:@"master_branch"];
        self.ref = [rawDictionary objectForKeyOrNilOnNullObject:@"ref"];
        self.refType = [rawDictionary objectForKeyOrNilOnNullObject:@"ref_type"];
        
        if (self.objectType == GHCreateEventObjectUnknown) {
            DLog(@"%@", rawDictionary);
            DLog(@"Detected Unkonw Create Event");
        }
    }
    return self;
}

#pragma mark - Memory management

- (void)dealloc {
    [_description release];
    [_masterBranch release];
    [_ref release];
    [_refType release];
    
    [super dealloc];
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.description forKey:@"description"];
    [aCoder encodeObject:self.masterBranch forKey:@"masterBranch"];
    [aCoder encodeObject:self.ref forKey:@"ref"];
    [aCoder encodeObject:self.refType forKey:@"refType"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        self.description = [aDecoder decodeObjectForKey:@"description"];
        self.masterBranch = [aDecoder decodeObjectForKey:@"masterBranch"];
        self.ref = [aDecoder decodeObjectForKey:@"ref"];
        self.refType = [aDecoder decodeObjectForKey:@"refType"];
    }
    return self;
}

@end
