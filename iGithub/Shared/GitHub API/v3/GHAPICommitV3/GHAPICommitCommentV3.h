//
//  GHAPICommitCommentV3.h
//  iGithub
//
//  Created by Oliver Letterer on 02.11.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHAPIUserV3.h"



/**
 @class     GHAPICommitCommentV3
 @abstract  <#abstract comment#>
 */
@interface GHAPICommitCommentV3 : NSObject <NSCoding> {
@private
    NSString *_URL;
    NSNumber *_ID;
    NSString *_body;
    NSString *_path;
    NSNumber *_position;
    NSString *_commitID;
    GHAPIUserV3 *_user;
    NSString *_createdAt;
    NSString *_updatedAt;
}

- (id)initWithRawDictionary:(NSDictionary *)rawDictionary;

@property (nonatomic, readonly) NSString *URL;
@property (nonatomic, readonly) NSNumber *ID;
@property (nonatomic, readonly) NSString *body;
@property (nonatomic, readonly) NSString *path;
@property (nonatomic, readonly) NSNumber *position;
@property (nonatomic, readonly) NSString *commitID;
@property (nonatomic, readonly) GHAPIUserV3 *user;
@property (nonatomic, readonly) NSString *createdAt;
@property (nonatomic, readonly) NSString *updatedAt;

@end
