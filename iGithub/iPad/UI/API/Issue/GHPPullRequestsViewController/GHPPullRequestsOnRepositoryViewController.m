//
//  GHPPullRequestsOnRepositoryViewController.m
//  iGithub
//
//  Created by Oliver Letterer on 07.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHPPullRequestsOnRepositoryViewController.h"


@implementation GHPPullRequestsOnRepositoryViewController

#pragma mark - setters and getters

- (void)setRepository:(NSString *)repository {
    [super setRepository:repository];
    
    [GHPullRequest pullRequestsOnRepository:self.repository 
                          completionHandler:^(NSArray *requests, NSError *error) {
                              if (error) {
                                  [self handleError:error];
                              } else {
                                  [self setDataArray:[requests mutableCopy] nextPage:GHAPIPaginationNextPageNotFound];
                              }
                          }];
}

@end
