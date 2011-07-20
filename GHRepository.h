//
//  GHRepository.h
//  iGithub
//
//  Created by Oliver Letterer on 01.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GHDirectory;

@interface GHRepository : NSObject <NSCoding> {
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
@property (nonatomic, readonly) NSString *fullName;

@property (nonatomic, readonly) BOOL hasLanguage;
@property (nonatomic, readonly) BOOL hasHomepage;
@property (nonatomic, readonly) BOOL isForked;

- (id)initWithRawDictionary:(NSDictionary *)rawDictionary;

+ (void)deleteTokenForRepository:(NSString *)repository 
           withCompletionHandler:(void (^)(NSString *deleteToken, NSError *error))handler;

+ (void)deleteRepository:(NSString *)repository 
               withToken:(NSString *)token 
       completionHandler:(void (^)(NSError *error))handler;

+ (void)filesOnRepository:(NSString *)repository 
                   branch:(NSString *)branch
        completionHandler:(void (^)(GHDirectory *rootDirectory, NSError *error))handler;

+ (void)searchRepositoriesWithSearchString:(NSString *)searchString 
                         completionHandler:(void(^)(NSArray *repos, NSError *error))handler;

@end
