//
//  GHIssuesCommentPayload.h
//  iGithub
//
//  Created by Oliver Letterer on 09.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GHPayloadWithRepository.h"

@interface GHIssuesCommentPayload : GHPayload {
    NSNumber *_commentID;
    NSNumber *_issueID;
}

- (id)initWithRawDictionary:(NSDictionary *)rawDictionary URL:(NSString *)URL;

@property (nonatomic, copy) NSNumber *commentID;
@property (nonatomic, copy) NSNumber *issueID;

@end
