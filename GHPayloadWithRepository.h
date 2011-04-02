//
//  GHPayloadWithRepository.h
//  iGithub
//
//  Created by Oliver Letterer on 02.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GHPayload.h"

@interface GHPayloadWithRepository : GHPayload {
    NSString *_repo;
}

@property (nonatomic, copy) NSString *repo;

@end
