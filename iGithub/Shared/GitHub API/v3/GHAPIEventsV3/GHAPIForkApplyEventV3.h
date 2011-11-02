//
//  GHAPIForkApplyEventEventV3.h
//  iGithub
//
//  Created by Oliver Letterer on 02.11.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHAPIEventV3.h"



/**
 @class     GHAPIForkApplyEventEventV3
 @abstract  Triggered when a patch is applied in the Fork Queue.
 */
@interface GHAPIForkApplyEventV3 : GHAPIEventV3 <NSCoding> {
@private
    NSString *_head;
    NSString *_before;
    NSString *_after;
}

@property (nonatomic, readonly) NSString *head;
@property (nonatomic, readonly) NSString *before;
@property (nonatomic, readonly) NSString *after;

@end
