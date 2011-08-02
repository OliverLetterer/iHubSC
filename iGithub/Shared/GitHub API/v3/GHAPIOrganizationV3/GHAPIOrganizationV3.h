//
//  GHAPIOrganizationV3.h
//  iGithub
//
//  Created by Oliver Letterer on 12.06.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GHAPIConnectionHandlersV3.h"

@class GHAPITeamV3;

@interface GHAPIOrganizationV3 : NSObject <NSCoding> {
@private
    NSString *_login;
    NSNumber *_ID;
    NSString *_URL;
    NSString *_avatarURL;
    NSString *_gravatarID;
    NSString *_name;
    NSString *_company;
    NSString *_blog;
    NSString *_location;
    NSString *_EMail;
    NSNumber *_publicRepos;
    NSNumber *_publicGists;
    NSNumber *_follower;
    NSNumber *_following;
    NSString *_HTMLURL;
    NSString *_createdAt;
    NSString *_type;
}

@property (nonatomic, copy) NSString *login;
@property (nonatomic, copy) NSNumber *ID;
@property (nonatomic, copy) NSString *URL;
@property (nonatomic, copy) NSString *avatarURL;
@property (nonatomic, copy) NSString *gravatarID;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *company;
@property (nonatomic, copy) NSString *blog;
@property (nonatomic, copy) NSString *location;
@property (nonatomic, copy) NSString *EMail;
@property (nonatomic, copy) NSNumber *publicRepos;
@property (nonatomic, copy) NSNumber *publicGists;
@property (nonatomic, copy) NSNumber *follower;
@property (nonatomic, copy) NSNumber *following;
@property (nonatomic, copy) NSString *HTMLURL;
@property (nonatomic, copy) NSString *createdAt;
@property (nonatomic, copy) NSString *type;

@property (nonatomic, readonly) BOOL hasEMail;
@property (nonatomic, readonly) BOOL hasLocation;
@property (nonatomic, readonly) BOOL hasBlog;

- (id)initWithRawDictionary:(NSDictionary *)rawDictionary;

+ (void)organizationsOfUser:(NSString *)username page:(NSUInteger)page completionHandler:(GHAPIPaginationHandler)handler;
+ (void)organizationByName:(NSString *)organizationName completionHandler:(void (^)(GHAPIOrganizationV3 *organization, NSError *error))handler;

+ (void)repositoriesOfOrganizationNamed:(NSString *)organizationName page:(NSUInteger)page completionHandler:(GHAPIPaginationHandler)handler;
+ (void)membersOfOrganizationNamed:(NSString *)organizationName page:(NSUInteger)page completionHandler:(GHAPIPaginationHandler)handler;
+ (void)teamsOfOrganizationNamed:(NSString *)organizationName page:(NSUInteger)page completionHandler:(GHAPIPaginationHandler)handler;

+ (void)isUser:(NSString *)username administratorInOrganization:(NSString *)organization completionHandler:(GHAPIStateHandler)handler;

+ (void)createTeamForOrganization:(NSString *)organization name:(NSString *)name permission:(NSString *)permission repositories:(NSArray *)repositories teamMembers:(NSArray *)teamMembers completionHandler:(void (^)(GHAPITeamV3 *team, NSError *error))handler;

// private
+ (void)isUser:(NSString *)username administratorInOrganization:(NSString *)organization nextPate:(NSUInteger)nextPage inArray:(NSMutableArray *)teamsArray currentTeamIndex:(NSUInteger)currentTeamIndex completionHandler:(GHAPIStateHandler)handler;
+ (void)isUser:(NSString *)username administratorInOrganization:(NSString *)organization checkTeamsWithPage:(NSUInteger)page completionHandler:(GHAPIStateHandler)handler;

@end
