//
//  GHAPIIssueCommentEventEventV3.h
//  iGithub
//
//  Created by Oliver Letterer on 02.11.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHAPIEventV3.h"
#import "GHAPIIssueV3.h"
#import "GHAPIIssueCommentV3.h"
#warning NSCoding



/**
 @class     GHAPIIssueCommentEventEventV3
 @abstract  <#abstract comment#>
 */
@interface GHAPIIssueCommentEventV3 : GHAPIEventV3 {
@private
    NSString *_action;
    GHAPIIssueV3 *_issue;
    GHAPIIssueCommentV3 *_comment;
}

@property (nonatomic, readonly) NSString *action;
@property (nonatomic, readonly) GHAPIIssueV3 *issue;
@property (nonatomic, readonly) GHAPIIssueCommentV3 *comment;

@end
