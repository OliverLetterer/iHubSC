//
//  GHPWatchedRepositoriesViewController.m
//  iGithub
//
//  Created by Oliver Letterer on 01.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHPWatchedRepositoriesViewController.h"


@implementation GHPWatchedRepositoriesViewController

#pragma mark - setters and getters

- (void)setUsername:(NSString *)username {
    [super setUsername:username];
    
    [GHAPIRepositoryV3 repositoriesThatUserIsWatching:username page:0 
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
    [GHAPIRepositoryV3 repositoriesThatUserIsWatching:self.username page:page 
                                    completionHandler:^(NSMutableArray *array, NSUInteger nextPage, NSError *error) {
                                        if (error) {
                                            [self handleError:error];
                                        } else {
                                            [self appendDataFromArray:array nextPage:nextPage];
                                        }
                                    }];
}
@end
