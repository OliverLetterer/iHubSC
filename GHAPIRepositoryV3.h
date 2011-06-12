//
//  GHAPIRepositoryV3.h
//  iGithub
//
//  Created by Oliver Letterer on 22.05.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GHAPIConnectionHandlersV3.h"

@class GHAPIUserV3, GHAPIOrganizationV3;

@interface GHAPIRepositoryV3 : NSObject {
@private
    NSString *_URL;
    NSString *_HTMLURL;
    GHAPIUserV3 *_owner;
    NSString *_name;
    NSString *_description;
    NSString *_homepage;
    NSString *_language;
    NSNumber *_private;
    NSNumber *_fork;
    NSNumber *_forks;
    NSNumber *_watchers;
    NSNumber *_size;
    NSNumber *_openIssues;
    NSString *_pushedAt;
    NSString *_createdAt;
    GHAPIOrganizationV3 *_organization;
    GHAPIRepositoryV3 *_parent;
    GHAPIRepositoryV3 *_source;
    NSString *_integralBranch;
    NSString *_masterBranch;
    NSNumber *_hasIssues;
    NSNumber *_hasWiki;
    NSNumber *_hasDownloads;
}

@property (nonatomic, copy) NSString *URL;
@property (nonatomic, copy) NSString *HTMLURL;
@property (nonatomic, retain) GHAPIUserV3 *owner;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *description;
@property (nonatomic, copy) NSString *homepage;
@property (nonatomic, copy) NSString *language;
@property (nonatomic, copy) NSNumber *private;
@property (nonatomic, copy) NSNumber *fork;
@property (nonatomic, copy) NSNumber *forks;
@property (nonatomic, copy) NSNumber *watchers;
@property (nonatomic, copy) NSNumber *size;
@property (nonatomic, copy) NSNumber *openIssues;
@property (nonatomic, copy) NSString *pushedAt;
@property (nonatomic, copy) NSString *createdAt;
@property (nonatomic, retain) GHAPIOrganizationV3 *organization;
@property (nonatomic, retain) GHAPIRepositoryV3 *parent;
@property (nonatomic, retain) GHAPIRepositoryV3 *source;
@property (nonatomic, copy) NSString *integralBranch;
@property (nonatomic, copy) NSString *masterBranch;
@property (nonatomic, copy) NSNumber *hasIssues;
@property (nonatomic, copy) NSNumber *hasWiki;
@property (nonatomic, copy) NSNumber *hasDownloads;

@property (nonatomic, readonly) BOOL hasLanguage;
@property (nonatomic, readonly) BOOL hasHomepage;
@property (nonatomic, readonly) BOOL isForked;

- (id)initWithRawDictionary:(NSDictionary *)rawDictionary;

+ (void)labelsOnRepository:(NSString *)repository page:(NSUInteger)page completionHandler:(GHAPIPaginationHandler)handler;

+ (void)repositoryNamed:(NSString *)repositoryName 
  withCompletionHandler:(void (^)(GHAPIRepositoryV3 *repository, NSError *error))handler;

+ (void)repositoriesForUserNamed:(NSString *)username page:(NSUInteger)page completionHandler:(GHAPIPaginationHandler)handler;

+ (void)repositoriesThatUserIsWatching:(NSString *)username page:(NSUInteger)page completionHandler:(GHAPIPaginationHandler)handler;

+ (void)watchersOfRepository:(NSString *)repository page:(NSUInteger)page completionHandler:(GHAPIPaginationHandler)handler;

+ (void)isWatchingRepository:(NSString *)repository completionHandler:(void (^)(BOOL watching, NSError *error))handler;

// will contain GHAPIRepositoryBranchV3
+ (void)branchesOnRepository:(NSString *)repository page:(NSUInteger)page completionHandler:(GHAPIPaginationHandler)handler;

+ (void)watchRepository:(NSString *)repository completionHandler:(GHAPIErrorHandler)handler;
+ (void)unwatchRepository:(NSString *)repository completionHandler:(GHAPIErrorHandler)handler;

+ (void)collaboratorsForRepository:(NSString *)repository page:(NSUInteger)page completionHandler:(GHAPIPaginationHandler)handler;
+ (void)isUser:(NSString *)username collaboratorOnRepository:(NSString *)repository completionHandler:(GHAPIStateHandler)handler;

+ (void)createRepositoryWithName:(NSString *)name description:(NSString *)description 
                          public:(BOOL)public completionHandler:(void (^)(GHAPIRepositoryV3 *repository, NSError *error))handler;

@end
