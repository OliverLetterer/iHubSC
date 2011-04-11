//
//  GHUser.h
//  iGithub
//
//  Created by Oliver Letterer on 29.03.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <dispatch/dispatch.h>

@interface GHUser : NSObject {
    NSString *_createdAt;
    NSUInteger _followersCount;
    NSUInteger _followingCount;
    NSString *_gravatarID;
    NSUInteger _ID;
    NSString *_login;
    NSUInteger _publicGistCount;
    NSUInteger _publicRepoCount;
    NSString *_type;
    
    // github private variables
    NSUInteger _privateRepoCount;
    NSUInteger _collaborators;
    NSUInteger _diskUsage;
    NSUInteger _ownedPrivateRepoCount;
    NSUInteger _privateGistCount;
    NSString *_planName;
    NSUInteger _planCollaborators;
    NSUInteger _planSpace;
    NSUInteger _planPrivateRepos;
    NSString *_password;
    
    NSString *_EMail;
    NSString *_location;
    NSString *_company;
    NSString *_blog;
    
    UIImage *_image;
}

@property (nonatomic, copy) NSString *createdAt;
@property (nonatomic, assign) NSUInteger followersCount;
@property (nonatomic, assign) NSUInteger followingCount;
@property (nonatomic, copy) NSString *gravatarID;
@property (nonatomic, assign) NSUInteger ID;
@property (nonatomic, copy) NSString *login;
@property (nonatomic, assign) NSUInteger publicGistCount;
@property (nonatomic, assign) NSUInteger publicRepoCount;
@property (nonatomic, copy) NSString *type;

// github private variables
@property (nonatomic, assign) NSUInteger privateRepoCount;
@property (nonatomic, assign) NSUInteger collaborators;
@property (nonatomic, assign) NSUInteger diskUsage;
@property (nonatomic, assign) NSUInteger ownedPrivateRepoCount;
@property (nonatomic, assign) NSUInteger privateGistCount;
@property (nonatomic, copy) NSString *planName;
@property (nonatomic, assign) NSUInteger planCollaborators;
@property (nonatomic, assign) NSUInteger planSpace;
@property (nonatomic, assign) NSUInteger planPrivateRepos;
@property (nonatomic, copy) NSString *password;

@property (nonatomic, copy) NSString *EMail;
@property (nonatomic, copy) NSString *location;
@property (nonatomic, copy) NSString *company;
@property (nonatomic, copy) NSString *blog;

@property (nonatomic, retain) UIImage *image;

@property (nonatomic, readonly) BOOL isAuthenticated;

+ (GHUser *)userFromRawUserDictionary:(NSDictionary *)rawDictionary;
- (id)initWithRawUserDictionary:(NSDictionary *)rawDictionary;
- (id)initWithRawDictionary:(NSDictionary *)rawDictionary;

+ (void)userWithName:(NSString *)username completionHandler:(void(^)(GHUser *user, NSError *error))handler;

+ (void)authenticatedUserWithUsername:(NSString *)username password:(NSString *)password completionHandler:(void(^)(GHUser *user, NSError *error))handler;

@end
