//
//  GHPushPayload.h
//  iGithub
//
//  Created by Oliver Letterer on 01.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GHPayload.h"

@interface GHPushPayload : GHPayload {
    NSString *_head;
    NSString *_ref;
    NSArray *_commits;
}

@property (nonatomic, copy) NSString *head;
@property (nonatomic, copy) NSString *ref;
@property (nonatomic, retain) NSArray *commits;

@end
