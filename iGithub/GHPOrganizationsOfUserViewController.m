//
//  GHPOrganizationsOfUserViewController.m
//  iGithub
//
//  Created by Oliver Letterer on 11.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHPOrganizationsOfUserViewController.h"


@implementation GHPOrganizationsOfUserViewController
@synthesize username=_username;

#pragma mark - setters and getters

- (void)setUsername:(NSString *)username {
    [_username release], _username = [username copy];
    
    [GHAPIOrganizationV3 organizationsOfUser:username page:1 
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
    [GHAPIOrganizationV3 organizationsOfUser:self.username page:page 
                           completionHandler:^(NSMutableArray *array, NSUInteger nextPage, NSError *error) {
                               if (error) {
                                   [self handleError:error];
                               } else {
                                   [self appendDataFromArray:array nextPage:nextPage];
                               }
                           }];
}
#pragma mark - Initialization

- (id)initWithUsername:(NSString *)username {
    if ((self = [super initWithStyle:UITableViewStyleGrouped])) {
        // Custom initialization
        self.username = username;
    }
    return self;
}

#pragma mark - Memory management

- (void)dealloc {
    [_username release];
    
    [super dealloc];
}

@end
