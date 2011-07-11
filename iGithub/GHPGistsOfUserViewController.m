//
//  GHPGistsOfUserViewController.m
//  iGithub
//
//  Created by Oliver Letterer on 07.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHPGistsOfUserViewController.h"


@implementation GHPGistsOfUserViewController
@synthesize username=_username;

#pragma mark - setters and getters

- (void)setUsername:(NSString *)username {
    [_username release], _username = [username copy];
    
    [GHAPIUserV3 gistsOfUser:username page:1 
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
    [GHAPIUserV3 gistsOfUser:self.username page:page 
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
