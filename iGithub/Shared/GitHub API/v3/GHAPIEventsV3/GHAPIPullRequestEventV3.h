//
//  GHAPIPullRequestEventEventV3.h
//  iGithub
//
//  Created by Oliver Letterer on 02.11.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHAPIEventV3.h"
#import "GHAPIPullRequestV3.h"



/**
 @class     GHAPIPullRequestEventEventV3
 @abstract  <#abstract comment#>
 */
@interface GHAPIPullRequestEventV3 : GHAPIEventV3 <NSCoding> {
@private
    GHAPIPullRequestV3 *_pullRequest;
    NSString *_action;
    NSNumber *_number;
}

@property (nonatomic, readonly) GHAPIPullRequestV3 *pullRequest;
@property (nonatomic, readonly) NSString *action;
@property (nonatomic, readonly) NSNumber *number;

@end
