//
//  GHAPIUserV3.h
//  iGithub
//
//  Created by Oliver Letterer on 21.05.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GHAPIConnectionHandlersV3.h"

@class GHAPIUserPlanV3;

@interface GHAPIUserV3 : NSObject <NSCoding> {
@private
    NSString *_login;
    NSNumber *_ID;
    NSString *_avatarURL;
    NSString *_gravatarID;
    NSString *_URL;
    NSString *_name;
    NSString *_company;
    NSString *_blog;
    NSString *_location;
    NSString *_EMail;
    NSNumber *_hireable;
    NSString *_bio;
    NSNumber *_publicRepos;
    NSNumber *_publicGists;
    NSNumber *_followers;
    NSNumber *_following;
    NSString *_htmlURL;
    NSString *_createdAt;
    NSString *_type;
    NSNumber *_totalPrivateRepos;
    NSNumber *_ownedPrivateRepos;
    NSNumber *_privateGists;
    NSNumber *_diskUsage;
    NSNumber *_collaborators;
    GHAPIUserPlanV3 *_plan;
}

- (BOOL)isEqualToUser:(GHAPIUserV3 *)user;

@property (nonatomic, copy) NSString *login;
@property (nonatomic, copy) NSNumber *ID;
@property (nonatomic, copy) NSString *avatarURL;
@property (nonatomic, copy) NSString *gravatarID;
@property (nonatomic, copy) NSString *URL;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *company;
@property (nonatomic, copy) NSString *blog;
@property (nonatomic, copy) NSString *location;
@property (nonatomic, copy) NSString *EMail;
@property (nonatomic, copy) NSNumber *hireable;
@property (nonatomic, copy) NSString *bio;
@property (nonatomic, copy) NSNumber *publicRepos;
@property (nonatomic, copy) NSNumber *publicGists;
@property (nonatomic, copy) NSNumber *followers;
@property (nonatomic, copy) NSNumber *following;
@property (nonatomic, copy) NSString *htmlURL;
@property (nonatomic, copy) NSString *createdAt;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSNumber *totalPrivateRepos;
@property (nonatomic, copy) NSNumber *ownedPrivateRepos;
@property (nonatomic, copy) NSNumber *privateGists;
@property (nonatomic, copy) NSNumber *diskUsage;
@property (nonatomic, copy) NSNumber *collaborators;
@property (nonatomic, retain) GHAPIUserPlanV3 *plan;

@property (nonatomic, readonly) BOOL hasEMail;
@property (nonatomic, readonly) BOOL hasLocation;
@property (nonatomic, readonly) BOOL hasCompany;
@property (nonatomic, readonly) BOOL hasBlog;

- (id)initWithRawDictionary:(NSDictionary *)rawDictionary;


+ (void)userWithName:(NSString *)username completionHandler:(void(^)(GHAPIUserV3 *user, NSError *error))handler;

+ (void)authenticatedUserWithUsername:(NSString *)username 
                             password:(NSString *)password 
                    completionHandler:(void(^)(GHAPIUserV3 *user, NSError *error))handler;

+ (void)usersThatUsernameIsFollowing:(NSString *)username page:(NSUInteger)page completionHandler:(GHAPIPaginationHandler)handler;

+ (void)usersThatAreFollowingUserNamed:(NSString *)username page:(NSUInteger)page completionHandler:(GHAPIPaginationHandler)handler;

+ (void)isFollowingUserNamed:(NSString *)username completionHandler:(void(^)(BOOL following, NSError *error))handler;

+ (void)followUser:(NSString *)username completionHandler:(void(^)(NSError *error))handler;
+ (void)unfollowUser:(NSString *)username completionHandler:(void(^)(NSError *error))handler;

+ (void)gistsOfUser:(NSString *)username page:(NSUInteger)page completionHandler:(GHAPIPaginationHandler)handler;

@end
