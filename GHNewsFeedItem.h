//
//  GHNewsFeedItem.h
//  iGithub
//
//  Created by Oliver Letterer on 01.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GHActorAttributes, GHPayload, GHRepository;

@interface GHNewsFeedItem : NSObject <NSCoding> {
    NSString *_actor;
    GHActorAttributes *_actorAttributes;
    NSString *_creationDate;
    GHPayload *_payload;
    NSNumber *_public;
    GHRepository *_repository;
    NSNumber *_times;
    NSString *_type;
    NSString *_URL;
}

@property (nonatomic, copy) NSString *actor;
@property (nonatomic, retain) GHActorAttributes *actorAttributes;
@property (nonatomic, copy) NSString *creationDate;
@property (nonatomic, retain) GHPayload *payload;
@property (nonatomic, copy) NSNumber *public;
@property (nonatomic, retain) GHRepository *repository;
@property (nonatomic, copy) NSNumber *times;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *URL;

- (id)initWithRawDictionary:(NSDictionary *)rawDictionary;

@end
