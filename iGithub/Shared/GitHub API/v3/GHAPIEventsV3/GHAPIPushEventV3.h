//
//  GHAPIPushEventEventV3.h
//  iGithub
//
//  Created by Oliver Letterer on 02.11.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHAPIEventV3.h"



/**
 @class     GHAPIPushEventEventV3
 @abstract  <#abstract comment#>
 */
@interface GHAPIPushEventV3 : GHAPIEventV3 <NSCoding> {
@private
    NSString *_head;
    NSString *_ref; // The full Git ref that was pushed. Example: “refs/heads/master”
    NSNumber *_numberOfCommits;
    NSArray *_commits;
}

@property (nonatomic, readonly) NSString *head;
@property (nonatomic, readonly) NSString *ref;
@property (nonatomic, readonly) NSNumber *numberOfCommits;
@property (nonatomic, readonly) NSArray *commits;

@property (nonatomic, readonly) NSString *branch;
@property (nonatomic, readonly) NSString *previewString;

@end
