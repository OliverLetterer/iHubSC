//
//  GHIssueComment.h
//  iGithub
//
//  Created by Oliver Letterer on 04.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GHUser;

@interface GHIssueComment : NSObject <NSCoding> {
    NSString *_body;
    NSString *_createdAt;
    NSString *_gravatarID;
    NSNumber *_ID;
    NSString *_updatedAt;
    NSString *_user;
    GHUser *_userInfo;
}

@property (nonatomic, copy) NSString *body;
@property (nonatomic, copy) NSString *createdAt;
@property (nonatomic, copy) NSString *gravatarID;
@property (nonatomic, copy) NSNumber *ID;
@property (nonatomic, copy) NSString *updatedAt;
@property (nonatomic, copy) NSString *user;
@property (nonatomic, retain) GHUser *userInfo;

- (id)initWithRawDictionary:(NSDictionary *)rawDictionary;

@end
