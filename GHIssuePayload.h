//
//  GHIssuePayload.h
//  iGithub
//
//  Created by Oliver Letterer on 01.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GHPayload.h"

@interface GHIssuePayload : GHPayload {
    NSString *_action;
    NSNumber *_issue;
    NSNumber *_number;
}

@property (nonatomic, copy) NSString *action;
@property (nonatomic, copy) NSNumber *issue;
@property (nonatomic, copy) NSNumber *number;

@end
