//
//  GHGist.h
//  iGithub
//
//  Created by Oliver Letterer on 03.05.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GHUser;

@interface GHGist : NSObject {
@private
    NSString *_URL;
    NSString *_ID;
    NSString *_description;
    NSNumber *_public;
    GHUser *_user;
    NSArray *_files;
    NSNumber *_comments;
    NSString *_pullURL;
    NSString *_pushURL;
    NSString *_createdAt;
    NSArray *_forks;
//    NSArray *_history;           // TODO: <------- no support yet for history
}

@property (nonatomic, copy) NSString *URL;
@property (nonatomic, copy) NSString *ID;
@property (nonatomic, copy) NSString *description;
@property (nonatomic, copy) NSNumber *public;
@property (nonatomic, retain) GHUser *user;
@property (nonatomic, retain) NSArray *files;
@property (nonatomic, copy) NSNumber *comments;
@property (nonatomic, copy) NSString *pullURL;
@property (nonatomic, copy) NSString *pushURL;
@property (nonatomic, copy) NSString *createdAt;
@property (nonatomic, retain) NSArray *forks;

- (id)initWithRawDictionary:(NSDictionary *)rawDictionay;

+ (void)gistWithID:(NSString *)ID completionHandler:(void(^)(GHGist *gist, NSError *error))handler;
+ (void)deleteGistWithID:(NSString *)ID completionHandler:(void(^)(NSError *error))handler;
+ (void)isGistStarredWithID:(NSString *)ID completionHandler:(void(^)(BOOL starred, NSError *error))handler;
+ (void)starGistWithID:(NSString *)ID completionHandler:(void(^)(NSError *error))handler;
+ (void)unstarGistWithID:(NSString *)ID completionHandler:(void(^)(NSError *error))handler;

@end
