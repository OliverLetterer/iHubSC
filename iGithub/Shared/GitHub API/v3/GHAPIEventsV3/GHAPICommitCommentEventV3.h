//
//  GHAPICommitCommentEventV3.h
//  iGithub
//
//  Created by Oliver Letterer on 02.11.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHAPIEventV3.h"
#import "GHAPICommitCommentV3.h"



/**
 @class     GHAPICommitCommentEventV3
 @abstract  <#abstract comment#>
 */
@interface GHAPICommitCommentEventV3 : GHAPIEventV3 <NSCoding> {
@private
    GHAPICommitCommentV3 *_comment;
}

@property (nonatomic, readonly) GHAPICommitCommentV3 *comment;

@end
