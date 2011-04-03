//
//  GHMemberEventPayload.h
//  iGithub
//
//  Created by Oliver Letterer on 03.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GHPayloadWithRepository.h"

@interface GHMemberEventPayload : GHPayloadWithRepository {
    NSString *_action;
    NSString *_member;
}

@property (nonatomic, copy) NSString *action;
@property (nonatomic, copy) NSString *member;

@end
