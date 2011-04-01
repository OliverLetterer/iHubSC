//
//  GHPullRequestPayload.h
//  iGithub
//
//  Created by Oliver Letterer on 01.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GHPayload.h"
#import "GHPullRequest.h"

@interface GHPullRequestPayload : GHPayload {
    NSNumber *_number;
    NSString *_action;
    GHPullRequest *_pullRequest;
}

@property (nonatomic, copy) NSNumber *number;
@property (nonatomic, copy) NSString *action;
@property (nonatomic, retain) GHPullRequest *pullRequest;

@end
