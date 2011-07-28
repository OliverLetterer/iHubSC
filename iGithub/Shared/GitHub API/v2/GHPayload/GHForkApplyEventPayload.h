//
//  GHForkApplyEventPayload.h
//  iGithub
//
//  Created by Oliver Letterer on 12.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GHPayloadWithRepository.h"

// :user applied fork commits
@interface GHForkApplyEventPayload : GHPayload {
@private
    NSString *_before;
    NSString *_head;
    NSString *_after;
}

@property (nonatomic, copy) NSString *before;
@property (nonatomic, copy) NSString *head;
@property (nonatomic, copy) NSString *after;

@end
