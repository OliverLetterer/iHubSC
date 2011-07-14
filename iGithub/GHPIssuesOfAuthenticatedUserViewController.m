//
//  GHPIssuesOfAuthenticatedUserViewController.m
//  iGithub
//
//  Created by Oliver Letterer on 14.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHPIssuesOfAuthenticatedUserViewController.h"


@implementation GHPIssuesOfAuthenticatedUserViewController

#pragma mark - setters and getters

- (void)setUsername:(NSString *)username {
    [super setUsername:username];
    
    [GHAPIIssueV3 issuesOfAuthenticatedUserOnPage:1 
                                completionHandler:^(NSMutableArray *array, NSUInteger nextPage, NSError *error) {
                                    self.isDownloadingEssentialData = NO;
                                    if (error) {
                                        [self handleError:error];
                                    } else {
                                        [self setDataArray:array nextPage:nextPage];
                                    }
                                }];
}

- (NSString *)descriptionStringForIssue:(GHAPIIssueV3 *)issue {
    return [NSString stringWithFormat:NSLocalizedString(@"Issue %@ on %@\n%@", @""), issue.number, issue.repository, issue.title];
}

#pragma mark - Pagination

- (void)downloadDataForPage:(NSUInteger)page inSection:(NSUInteger)section {
    [GHAPIIssueV3 issuesOfAuthenticatedUserOnPage:page 
                                completionHandler:^(NSMutableArray *array, NSUInteger nextPage, NSError *error) {
                                    if (error) {
                                        [self handleError:error];
                                    } else {
                                        [self appendDataFromArray:array nextPage:nextPage];
                                    }
                                }];
}

@end
