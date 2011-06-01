//
//  GHGollumEventPayload.h
//  iGithub
//
//  Created by Oliver Letterer on 03.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GHPayloadWithRepository.h"

// :user created/deleted :pageName in Wiki
@interface GHGollumEventPayload : GHPayload {
    NSString *_action;
    NSString *_pageName;
    NSString *_sha;
    NSString *_summary;
    NSString *_title;
}

@property (nonatomic, copy) NSString *action;
@property (nonatomic, copy) NSString *pageName;
@property (nonatomic, copy) NSString *sha;
@property (nonatomic, copy) NSString *summary;
@property (nonatomic, copy) NSString *title;

@end
