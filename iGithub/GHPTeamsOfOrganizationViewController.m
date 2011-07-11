//
//  GHPTeamsOfOrganizationViewController.m
//  iGithub
//
//  Created by Oliver Letterer on 11.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHPTeamsOfOrganizationViewController.h"


@implementation GHPTeamsOfOrganizationViewController

#pragma mark - setters and getters

- (void)setOrganizationName:(NSString *)organizationName {
    [super setOrganizationName:organizationName];
    
    [GHAPIOrganizationV3 teamsOfOrganizationNamed:self.organizationName page:1 
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
    [GHAPIOrganizationV3 teamsOfOrganizationNamed:self.organizationName page:page 
                                completionHandler:^(NSMutableArray *array, NSUInteger nextPage, NSError *error) {
                                    if (error) {
                                        [self handleError:error];
                                    } else {
                                        [self appendDataFromArray:array nextPage:nextPage];
                                    }
                                }];
}

@end
