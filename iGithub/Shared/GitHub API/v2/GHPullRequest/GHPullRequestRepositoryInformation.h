//
//  GHPullRequestRepositoryInformation.h
//  iGithub
//
//  Created by Oliver Letterer on 16.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GithubAPI.h"

@interface GHPullRequestRepositoryInformation : NSObject <NSCoding> {
@private
    NSString *_label;
    NSString *_ref;
    GHRepository *_repository;
    NSString *_sha;
    GHUser *_user;
}

@property (nonatomic, copy) NSString *label;
@property (nonatomic, copy) NSString *ref;
@property (nonatomic, retain) GHRepository *repository;
@property (nonatomic, copy) NSString *sha;
@property (nonatomic, retain) GHUser *user;

- (id)initWithRawDictionary:(NSDictionary *)rawDictionary;

@end
