//
//  GHPWatchingRepositoryUsersViewController.m
//  iGithub
//
//  Created by Oliver Letterer on 02.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHPWatchingRepositoryUsersViewController.h"


@implementation GHPWatchingRepositoryUsersViewController

#pragma mark - setters and getters

- (void)setRepository:(NSString *)repository {
    [super setRepository:repository];
    
    [GHAPIRepositoryV3 watchersOfRepository:repository page:1 
                          completionHandler:^(NSMutableArray *array, NSUInteger nextPage, NSError *error) {
                              self.isDownloadingEssentialData = NO;
                              if (error) {
                                  [self handleError:error];
                              } else {
                                  [self setDataArray:array nextPage:nextPage];
                              }
                          }];
}

#pragma mark - Pagination

- (void)downloadDataForPage:(NSUInteger)page inSection:(NSUInteger)section {
    [GHAPIRepositoryV3 watchersOfRepository:self.repository page:page 
                              completionHandler:^(NSMutableArray *array, NSUInteger nextPage, NSError *error) {
                                  if (error) {
                                      [self handleError:error];
                                  } else {
                                      [self appendDataFromArray:array nextPage:nextPage];
                                  }
                              }];
}

@end
