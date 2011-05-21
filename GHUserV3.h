//
//  GHUserV3.h
//  iGithub
//
//  Created by Oliver Letterer on 21.05.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GHUserPlan;

@interface GHUserV3 : NSObject {
@private
    NSString *_login;
    NSNumber *_ID;
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
    GHUserPlan *_plan;
}

@property (nonatomic, copy) NSString *login;
@property (nonatomic, copy) NSNumber *ID;
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
@property (nonatomic, retain) GHUserPlan *plan;

- (id)initWithRawDictionary:(NSDictionary *)rawDictionay;


+ (void)userWithName:(NSString *)username completionHandler:(void(^)(GHUserV3 *user, NSError *error))handler;

+ (void)authenticatedUserWithUsername:(NSString *)username 
                             password:(NSString *)password 
                    completionHandler:(void(^)(GHUserV3 *user, NSError *error))handler;

+ (void)usersThatUsernameIsFollowing:(NSString *)username completionHandler:(void(^)(NSArray *users, NSError *error))handler;

+ (void)userThatAreFollowingUserNamed:(NSString *)username completionHandler:(void(^)(NSArray *users, NSError *error))handler;

+ (void)isFollowingUserNamed:(NSString *)username completionHandler:(void(^)(BOOL following, NSError *error))handler;

+ (void)followUser:(NSString *)username completionHandler:(void(^)(NSError *error))handler;
+ (void)unfollowUser:(NSString *)username completionHandler:(void(^)(NSError *error))handler;

+ (void)gistsOfUser:(NSString *)username page:(NSInteger)page completionHandler:(void (^)(NSArray *gists, NSInteger nextPage, NSError *error))handler;

@end
