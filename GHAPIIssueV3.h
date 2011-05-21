//
//  GHAPIIssueV3.h
//  iGithub
//
//  Created by Oliver Letterer on 30.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GHUserV3, GHAPIMilestoneV3, GHIssueCommentV3;

@interface GHAPIIssueV3 : NSObject {
@private
    GHUserV3 *_assignee;
    NSString *_body;
    NSString *_closedAt;
    NSNumber *_comments;
    NSString *_createdAt;
    NSString *_HTMLURL;
    NSArray *_labels;
    GHAPIMilestoneV3 *_milestone;
    NSNumber *_number;
    NSNumber *_pullRequestID;
    NSString *_state;
    NSString *_title;
    NSString *_updatedAt;
    NSString *_URL;
    GHUserV3 *_user;
}

@property (nonatomic, retain) GHUserV3 *assignee;
@property (nonatomic, copy) NSString *body;
@property (nonatomic, copy) NSString *closedAt;
@property (nonatomic, copy) NSNumber *comments;
@property (nonatomic, copy) NSString *createdAt;
@property (nonatomic, copy) NSString *HTMLURL;
@property (nonatomic, copy) NSArray *labels;
@property (nonatomic, retain) GHAPIMilestoneV3 *milestone;
@property (nonatomic, copy) NSNumber *number;
@property (nonatomic, copy) NSNumber *pullRequestID;
@property (nonatomic, copy) NSString *state;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *updatedAt;
@property (nonatomic, copy) NSString *URL;
@property (nonatomic, retain) GHUserV3 *user;

- (id)initWithRawDictionary:(NSDictionary *)rawDictionay;


+ (void)openedIssuesOnRepository:(NSString *)repository 
                            page:(NSInteger)page
               completionHandler:(void (^)(NSArray *issues, NSInteger nextPage, NSError *error))handler;

+ (void)issueOnRepository:(NSString *)repository 
               withNumber:(NSNumber *)number 
        completionHandler:(void (^)(GHAPIIssueV3 *issue, NSError *error))handler;

+ (void)milestonesForIssueOnRepository:(NSString *)repository 
                            withNumber:(NSNumber *)number 
                                  page:(NSInteger)page
                     completionHandler:(void (^)(NSArray *milestones, NSInteger nextPage, NSError *error))handler;

+ (void)createIssueOnRepository:(NSString *)repository 
                          title:(NSString *)title 
                           body:(NSString *)body 
                       assignee:(NSString *)assignee 
                      milestone:(NSNumber *)milestone
              completionHandler:(void (^)(GHAPIIssueV3 *issue, NSError *error))handler;

+ (void)commentsForIssueOnRepository:(NSString *)repository 
                          withNumber:(NSNumber *)number 
                   completionHandler:(void (^)(NSArray *comments, NSError *error))handler;

+ (void)postComment:(NSString *)comment forIssueOnRepository:(NSString *)repository 
         withNumber:(NSNumber *)number 
  completionHandler:(void (^)(GHIssueCommentV3 *comment, NSError *error))handler;

@end
