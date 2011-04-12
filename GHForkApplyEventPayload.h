//
//  GHForkApplyEventPayload.h
//  iGithub
//
//  Created by Oliver Letterer on 12.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GHPayloadWithRepository.h"

@interface GHForkApplyEventPayload : GHPayloadWithRepository {
@private
    NSString *_commit;
    NSString *_head;
    NSString *_original;
}

@property (nonatomic, copy) NSString *commit;
@property (nonatomic, copy) NSString *head;
@property (nonatomic, copy) NSString *original;

@end
