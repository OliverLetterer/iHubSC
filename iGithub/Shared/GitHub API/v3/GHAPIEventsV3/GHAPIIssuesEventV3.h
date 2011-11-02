//
//  GHAPIIssuesEventEventV3.h
//  iGithub
//
//  Created by Oliver Letterer on 02.11.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHAPIEventV3.h"
#import "GHAPIIssueV3.h"
#warning NSCoding



/**
 @class     GHAPIIssuesEventEventV3
 @abstract  <#abstract comment#>
 */
@interface GHAPIIssuesEventV3 : GHAPIEventV3 {
@private
    NSString *_action;
    GHAPIIssueV3 *_issue;
}

@property (nonatomic, readonly) NSString *action;
@property (nonatomic, readonly) GHAPIIssueV3 *issue;

@end
