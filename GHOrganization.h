//
//  GHOrganization.h
//  iGithub
//
//  Created by Oliver Letterer on 26.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface GHOrganization : NSObject {
@private
    NSString *_name;
    id _company;
    NSString *_gravatarID;
    NSString *_location;
    NSString *_createdAt;
    NSString *_blog;
    NSNumber *_publicGistCount;
    NSNumber *_publicRepoCount;
    NSNumber *_followingCount;
    NSNumber *_ID;
    id _permission;
    NSString *_type;
    NSString *_followersCount;
    NSString *_login;
    NSString *_EMail;
}

@property (nonatomic, copy) NSString *name;
//id _company;
@property (nonatomic, copy) NSString *gravatarID;
@property (nonatomic, copy) NSString *location;
@property (nonatomic, copy) NSString *createdAt;
@property (nonatomic, copy) NSString *blog;
@property (nonatomic, copy) NSNumber *publicGistCount;
@property (nonatomic, copy) NSNumber *publicRepoCount;
@property (nonatomic, copy) NSNumber *followingCount;
@property (nonatomic, copy) NSNumber *ID;
//id _permission;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *followersCount;
@property (nonatomic, copy) NSString *login;
@property (nonatomic, copy) NSString *EMail;

- (id)initWithRawDictionary:(NSDictionary *)dictionary;

+ (void)organizationsOfUser:(NSString *)username completionHandler:(void(^)(NSArray *organizations, NSError *error))handler;
+ (void)organizationsNamed:(NSString *)name completionHandler:(void(^)(GHOrganization *organization, NSError *error))handler;

- (void)publicRepositoriesWithCompletionHandler:(void(^)(NSArray *repositories, NSError *error))handler;
- (void)publicMembersWithCompletionHandler:(void(^)(NSArray *members, NSError *error))handler;

@end
