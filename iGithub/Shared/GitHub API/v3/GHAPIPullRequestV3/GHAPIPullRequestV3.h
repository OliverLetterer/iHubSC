//
//  GHAPIPullRequestV3.h
//  iGithub
//
//  Created by Oliver Letterer on 05.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GHAPIPullRequestMergeStateV3, GHAPIUserV3;



@interface GHAPIPullRequestV3 : NSObject <NSCoding> {
@private
    NSNumber *_ID;
    NSString *_state;
    NSString *_title;
    NSString *_body;
    NSString *_createdAt;
    NSString *_updatedAt;
    NSString *_closedAt;
    NSString *_mergedAt;
    NSNumber *_merged;
    NSNumber *_isMergable;
    GHAPIUserV3 *_mergedBy;
    NSNumber *_comments;
    NSNumber *_commits;
    NSNumber *_additions;
    NSNumber *_deletions;
    NSNumber *_changedFiles;
}

@property (nonatomic, strong) NSNumber *ID;
@property (nonatomic, strong) NSString *state;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *body;
@property (nonatomic, strong) NSString *createdAt;
@property (nonatomic, strong) NSString *updatedAt;
@property (nonatomic, strong) NSString *closedAt;
@property (nonatomic, strong) NSString *mergedAt;
@property (nonatomic, strong) NSNumber *merged;
@property (nonatomic, strong) NSNumber *isMergable;
@property (nonatomic, strong) GHAPIUserV3 *mergedBy;
@property (nonatomic, strong) NSNumber *comments;
@property (nonatomic, strong) NSNumber *commits;
@property (nonatomic, strong) NSNumber *additions;
@property (nonatomic, strong) NSNumber *deletions;
@property (nonatomic, strong) NSNumber *changedFiles;

- (id)initWithRawDictionary:(NSDictionary *)rawDictionary;

+ (void)mergPullRequestOnRepository:(NSString *)repository 
                         withNumber:(NSNumber *)pullRequestNumber 
                      commitMessage:(NSString *)commitMessage
                  completionHandler:(void(^)(GHAPIPullRequestMergeStateV3 *state, NSError *error))handler;

+ (void)commitsOfPullRequestOnRepository:(NSString *)repository 
                              withNumber:(NSNumber *)pullRequestNumber 
                       completionHandler:(void(^)(NSArray *commits, NSError *error))completionHandler;

@end
