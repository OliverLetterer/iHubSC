//
//  GHAPIPullRequestV3.h
//  iGithub
//
//  Created by Oliver Letterer on 05.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GHAPIPullRequestMergeStateV3;

@interface GHAPIPullRequestV3 : NSObject {
@private
    
}

+ (void)mergPullRequestOnRepository:(NSString *)repository 
                         withNumber:(NSNumber *)pullRequestNumber 
                      commitMessage:(NSString *)commitMessage
                  completionHandler:(void(^)(GHAPIPullRequestMergeStateV3 *state, NSError *error))handler;

+ (void)commitsOfPullRequestOnRepository:(NSString *)repository 
                              withNumber:(NSNumber *)pullRequestNumber 
                       completionHandler:(void(^)(NSArray *commits, NSError *error))completionHandler;

@end
