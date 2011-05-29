//
//  GHRepository.h
//  iGithub
//
//  Created by Oliver Letterer on 01.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GHDirectory;

@interface GHRepository : NSObject {
    NSString *_creationDate;
    NSString *_desctiptionRepo;
    NSNumber *_fork;
    NSNumber *_forks;
    NSNumber *_hasDownloads;
    NSNumber *_hasIssues;
    NSNumber *_hasWiki;
    NSString *_homePage;
    NSString *_integrateBranch;
    NSString *_language;
    NSString *_name;
    NSNumber *_openIssues;
    NSString *_owner;
    NSString *_parent;
    NSNumber *_private;
    NSString *_pushedAt;
    NSNumber *_size;
    NSString *_source;
    NSString *_URL;
    NSNumber *_watchers;
}

@property (nonatomic, copy) NSString *creationDate;
@property (nonatomic, copy) NSString *desctiptionRepo;
@property (nonatomic, copy) NSNumber *fork;
@property (nonatomic, copy) NSNumber *forks;
@property (nonatomic, copy) NSNumber *hasDownloads;
@property (nonatomic, copy) NSNumber *hasIssues;
@property (nonatomic, copy) NSNumber *hasWiki;
@property (nonatomic, copy) NSString *homePage;
@property (nonatomic, copy) NSString *integrateBranch;
@property (nonatomic, copy) NSString *language;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSNumber *openIssues;
@property (nonatomic, copy) NSString *owner;
@property (nonatomic, copy) NSString *parent;
@property (nonatomic, copy) NSNumber *private;
@property (nonatomic, copy) NSString *pushedAt;
@property (nonatomic, copy) NSNumber *size;
@property (nonatomic, copy) NSString *source;
@property (nonatomic, copy) NSString *URL;
@property (nonatomic, copy) NSNumber *watchers;

@property (nonatomic, readonly) BOOL isHomepageAvailable;

- (id)initWithRawDictionary:(NSDictionary *)rawDictionary;

+ (void)collaboratorsForRepository:(NSString *)repository 
                 completionHandler:(void (^)(NSArray *array, NSError *error))handler;

+ (void)repositoriesForUserNamed:(NSString *)username 
               completionHandler:(void (^)(NSArray *array, NSError *error))handler;

+ (void)createRepositoryWithTitle:(NSString *)title 
                      description:(NSString *)description 
                           public:(BOOL)public 
                completionHandler:(void (^)(GHRepository *repository, NSError *error))handler;

+ (void)watchedRepositoriesOfUser:(NSString *)username 
                completionHandler:(void (^)(NSArray *array, NSError *error))handler;

+ (void)repository:(NSString *)repository withCompletionHandler:(void (^)(GHRepository *repository, NSError *error))handler;

+ (void)watchingUserOfRepository:(NSString *)repository 
          withCompletionHandler:(void (^)(NSArray *watchingUsers, NSError *error))handler;

+ (void)deleteTokenForRepository:(NSString *)repository 
           withCompletionHandler:(void (^)(NSString *deleteToken, NSError *error))handler;

+ (void)deleteRepository:(NSString *)repository 
               withToken:(NSString *)token 
       completionHandler:(void (^)(NSError *error))handler;

+ (void)followRepositorie:(NSString *)repository completionHandler:(void (^)(NSError *error))handler;
+ (void)unfollowRepositorie:(NSString *)repository completionHandler:(void (^)(NSError *error))handler;

+ (void)branchesOnRepository:(NSString *)repository 
           completionHandler:(void (^)(NSArray *array, NSError *error))handler;

+ (void)recentCommitsOnRepository:(NSString *)repository 
                           branch:(NSString *)branch
                completionHandler:(void (^)(NSArray *array, NSError *error))handler;

+ (void)filesOnRepository:(NSString *)repository 
                   branch:(NSString *)branch
        completionHandler:(void (^)(GHDirectory *rootDirectory, NSError *error))handler;

+ (void)searchRepositoriesWithSearchString:(NSString *)searchString 
                         completionHandler:(void(^)(NSArray *repos, NSError *error))handler;

@end
