//
//  GHPullRequest.h
//  iGithub
//
//  Created by Oliver Letterer on 01.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GHPullRequestDiscussion;

@interface GHPullRequest : NSObject {
    NSNumber *_additions;
    NSNumber *_commits;
    NSNumber *_deletions;
    NSNumber *_ID;
    NSNumber *_issueID;
    NSNumber *_number;
    NSString *_title;
}

@property (nonatomic, copy) NSNumber *additions;
@property (nonatomic, copy) NSNumber *commits;
@property (nonatomic, copy) NSNumber *deletions;
@property (nonatomic, copy) NSNumber *ID;
@property (nonatomic, copy) NSNumber *issueID;
@property (nonatomic, copy) NSNumber *number;
@property (nonatomic, copy) NSString *title;

- (id)initWithRawDictionary:(NSDictionary *)rawDictionary;

+ (void)pullRequestDiscussionOnRepository:(NSString *)repository 
                                   number:(NSNumber *)number 
                        completionHandler:(void(^)(GHPullRequestDiscussion *discussion, NSError *error))handler;

@end
