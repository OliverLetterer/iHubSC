//
//  GHPCommitsOfPullRequestViewController.m
//  iGithub
//
//  Created by Oliver Letterer on 11.11.11.
//  Copyright (c) 2011 Home. All rights reserved.
//

#import "GHPCommitsOfPullRequestViewController.h"




@implementation GHPCommitsOfPullRequestViewController

- (id)initWithRepositoryString:(NSString *)repositoryString issueNumber:(NSNumber *)issueNumber {
    if (self = [super initWithStyle:UITableViewStyleGrouped]) {
        _repository = repositoryString;
        _issueNumber = issueNumber;
        
        [GHAPIPullRequestV3 commitsOfPullRequestOnRepository:_repository 
                                                  withNumber:_issueNumber 
                                           completionHandler:^(NSArray *commits, NSError *error) {
                                               self.isDownloadingEssentialData = NO;
                                               
                                               if (error) {
                                                   [self handleError:error];
                                               } else {
                                                   [self setDataArray:commits.mutableCopy nextPage:GHAPIPaginationNextPageNotFound];
                                               }
                                           }];
    }
    return self;
}

@end
