//
//  GHPayloadWithRepository.h
//  iGithub
//
//  Created by Oliver Letterer on 02.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GHPayloadWithActor.h"

@class GHRepository;

@interface GHPayloadWithRepository : GHPayloadWithActor {
    GHRepository *_repository;
}

@property (nonatomic, retain) GHRepository *repository;
@property (nonatomic, readonly) NSString *repo;

@end
