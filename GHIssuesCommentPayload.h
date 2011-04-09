//
//  GHIssuesCommentPayload.h
//  iGithub
//
//  Created by Oliver Letterer on 09.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GHPayloadWithRepository.h"

@interface GHIssuesCommentPayload : GHPayloadWithRepository {
    NSNumber *_commentID;
    NSNumber *_issueID;
}

@property (nonatomic, copy) NSNumber *commentID;
@property (nonatomic, copy) NSNumber *issueID;

@end
