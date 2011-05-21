//
//  GHAPIGistV3.h
//  iGithub
//
//  Created by Oliver Letterer on 03.05.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GHAPIUserV3, GHAPIGistCommentV3;

@interface GHAPIGistV3 : NSObject {
@private
    NSString *_URL;
    NSString *_ID;
    NSString *_description;
    NSNumber *_public;
    GHAPIUserV3 *_user;
    NSArray *_files;
    NSNumber *_comments;
    NSString *_pullURL;
    NSString *_pushURL;
    NSString *_createdAt;
    NSArray *_forks;
//    NSArray *_history;           // TODO: GHAPIGistV3::_history not supported yet
}

@property (nonatomic, copy) NSString *URL;
@property (nonatomic, copy) NSString *ID;
@property (nonatomic, copy) NSString *description;
@property (nonatomic, copy) NSNumber *public;
@property (nonatomic, retain) GHAPIUserV3 *user;
@property (nonatomic, retain) NSArray *files;   // contains GHAPIGistFileV3's
@property (nonatomic, copy) NSNumber *comments;
@property (nonatomic, copy) NSString *pullURL;
@property (nonatomic, copy) NSString *pushURL;
@property (nonatomic, copy) NSString *createdAt;
@property (nonatomic, retain) NSArray *forks;   // contains GHAPIGistForkV3's

- (id)initWithRawDictionary:(NSDictionary *)rawDictionay;

+ (void)gistWithID:(NSString *)ID completionHandler:(void(^)(GHAPIGistV3 *gist, NSError *error))handler;
+ (void)deleteGistWithID:(NSString *)ID completionHandler:(void(^)(NSError *error))handler;
+ (void)isGistStarredWithID:(NSString *)ID completionHandler:(void(^)(BOOL starred, NSError *error))handler;
+ (void)starGistWithID:(NSString *)ID completionHandler:(void(^)(NSError *error))handler;
+ (void)unstarGistWithID:(NSString *)ID completionHandler:(void(^)(NSError *error))handler;

+ (void)commentsForGistWithID:(NSString *)ID completionHandler:(void(^)(NSMutableArray *comments, NSError *error))handler;
+ (void)postComment:(NSString *)comment forGistWithID:(NSString *)ID completionHandler:(void(^)(GHAPIGistCommentV3 *comment, NSError *error))handler;

@end
