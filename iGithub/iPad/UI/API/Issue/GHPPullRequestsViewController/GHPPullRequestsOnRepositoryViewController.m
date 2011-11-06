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
    
    [GHAPIPullRequestV3 pullRequestsOnRepository:self.repository 
                                            page:1 
                               completionHandler:^(NSMutableArray *array, NSUInteger nextPage, NSError *error) {
                                   if (error) {
                                       [self handleError:error];
                                   } else {
                                       [self setDataArray:array nextPage:nextPage];
                                   }
                               }];
}

- (void)downloadDataForPage:(NSUInteger)page inSection:(NSUInteger)section
{
    [GHAPIPullRequestV3 pullRequestsOnRepository:self.repository 
                                            page:page
                               completionHandler:^(NSMutableArray *array, NSUInteger nextPage, NSError *error) {
                                   if (error) {
                                       [self handleError:error];
                                   } else {
                                       [self appendDataFromArray:array nextPage:nextPage];
                                   }
                               }];
}

@end
