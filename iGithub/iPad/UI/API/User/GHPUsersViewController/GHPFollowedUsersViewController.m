//
//  GHPFollowedUsersViewController.m
//  iGithub
//
//  Created by Oliver Letterer on 02.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHPFollowedUsersViewController.h"


@implementation GHPFollowedUsersViewController

#pragma mark - setters and getters

- (void)setUsername:(NSString *)username {
    [super setUsername:username];
    
    [GHAPIUserV3 usersThatAreFollowingUserNamed:self.username page:1 
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
    [GHAPIUserV3 usersThatAreFollowingUserNamed:self.username page:page 
                            completionHandler:^(NSMutableArray *array, NSUInteger nextPage, NSError *error) {
                                if (error) {
                                    [self handleError:error];
                                } else {
                                    [self appendDataFromArray:array nextPage:nextPage];
                                }
                            }];
}

@end
