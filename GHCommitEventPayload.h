//
//  GHCommitEventPayload.h
//  iGithub
//
//  Created by Oliver Letterer on 02.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GHPayloadWithRepository.h"

@interface GHCommitEventPayload : GHPayloadWithRepository {
    NSNumber *_commentID;
    NSString *_commit;
}

@property (nonatomic, copy) NSNumber *commentID;
@property (nonatomic, copy) NSString *commit;

@end
