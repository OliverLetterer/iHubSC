//
//  GHAPITeamV3.h
//  iGithub
//
//  Created by Oliver Letterer on 12.06.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GHAPIConnectionHandlersV3.h"

extern NSString *const GHAPITeamV3PermissionPull;
extern NSString *const GHAPITeamV3PermissionPush;
extern NSString *const GHAPITeamV3PermissionAdmin;

@interface GHAPITeamV3 : NSObject <NSCoding> {
@private
    NSString *_URL;
    NSString *_name;
    NSNumber *_ID;
    NSString *_permission;
    NSNumber *_membersCount;
    NSNumber *_reposCount;
}

@property (nonatomic, copy) NSString *URL;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSNumber *ID;
@property (nonatomic, copy) NSString *permission;
@property (nonatomic, copy) NSNumber *membersCount;
@property (nonatomic, copy) NSNumber *reposCount;

- (id)initWithRawDictionary:(NSDictionary *)rawDictionary;

+ (void)teamByID:(NSNumber *)teamID completionHandler:(void (^)(GHAPITeamV3 *team, NSError *error))handler;

+ (void)deleteTeamWithID:(NSNumber *)teamID completionHandler:(GHAPIErrorHandler)handler;

+ (void)membersOfTeamByID:(NSNumber *)teamID page:(NSUInteger)page completionHandler:(GHAPIPaginationHandler)handler;
+ (void)repositoriesOfTeamByID:(NSNumber *)teamID page:(NSUInteger)page completionHandler:(GHAPIPaginationHandler)handler;
+ (void)teamByID:(NSNumber *)teamID deleteUserNamed:(NSString *)username completionHandler:(GHAPIErrorHandler)handler;
+ (void)teamByID:(NSNumber *)teamID deleteRepositoryNamed:(NSString *)repository completionHandler:(GHAPIErrorHandler)handler;

+ (void)isUser:(NSString *)username memberInTeamByID:(NSNumber *)teamID completionHandler:(GHAPIStateHandler)handler;

+ (void)updateTeamWithID:(NSNumber *)teamID setTeamMembers:(NSArray *)teamMembers completionHandler:(GHAPIErrorHandler)handler;

+ (void)teamByID:(NSNumber *)teamID addUserNamed:(NSString *)username completionHandler:(GHAPIErrorHandler)handler;

// private
+ (void)allMembersOfTeamWithID:(NSNumber *)teamID completionHandler:(void (^)(NSMutableArray *members, NSError *error))handler;
+ (void)_dumpMembersOfTeamWithID:(NSNumber *)teamID inArray:(NSMutableArray *)membersArray page:(NSUInteger)page completionHandler:(GHAPIErrorHandler)handler;

+ (void)teamWithID:(NSNumber *)teamID removeMembersFromArray:(NSArray *)array completionHandler:(GHAPIErrorHandler)handler;
+ (void)_teamWithID:(NSNumber *)teamID removeMembersFromArray:(NSArray *)membersToRemove currentMemberIndex:(NSUInteger)currentMemberIndex completionHandler:(GHAPIErrorHandler)handler;

@end
