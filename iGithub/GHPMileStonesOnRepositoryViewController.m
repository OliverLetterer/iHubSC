//
//  GHPMileStonesOnRepositoryViewController.m
//  iGithub
//
//  Created by Oliver Letterer on 05.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHPMileStonesOnRepositoryViewController.h"


@implementation GHPMileStonesOnRepositoryViewController

#pragma mark - setters and getters

- (void)setRepository:(NSString *)repository {
    [super setRepository:repository];
    
    [GHAPIIssueV3 milestonesForIssueOnRepository:self.repository withNumber:nil page:1 
                               completionHandler:^(NSMutableArray *array, NSUInteger nextPage, NSError *error) {
                                   if (error) {
                                       [self handleError:error];
                                   } else {
                                       [self setDataArray:array nextPage:nextPage];
                                   }
                               }];
}

#pragma mark - Pagination

- (void)downloadDataForPage:(NSUInteger)page inSection:(NSUInteger)section {
    [GHAPIIssueV3 milestonesForIssueOnRepository:self.repository withNumber:nil page:page 
                               completionHandler:^(NSMutableArray *array, NSUInteger nextPage, NSError *error) {
                                   if (error) {
                                       [self handleError:error];
                                   } else {
                                       [self appendDataFromArray:array nextPage:nextPage];
                                   }
                               }];
}

@end
