//
//  GHPOpenIssuesOnRepositoryViewController.m
//  iGithub
//
//  Created by Oliver Letterer on 04.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHPOpenIssuesOnRepositoryViewController.h"


@implementation GHPOpenIssuesOnRepositoryViewController

@synthesize repository=_repository;

#pragma mark - setters and getters

- (void)setRepository:(NSString *)repository {
    [_repository release];
    _repository = [repository copy];
    
    self.isDownloadingEssentialData = YES;
    [GHAPIIssueV3 openedIssuesOnRepository:_repository page:1 
                         completionHandler:^(NSMutableArray *array, NSUInteger nextPage, NSError *error) {
                             self.isDownloadingEssentialData = NO;
                             if (error) {
                                 [self handleError:error];
                             } else {
                                 [self setNextPage:nextPage forSection:0];
                                 self.issues = array;
                             }
                         }];
}

#pragma mark - Pagination

- (void)downloadDataForPage:(NSUInteger)page inSection:(NSUInteger)section {
    [GHAPIIssueV3 openedIssuesOnRepository:_repository page:page 
                         completionHandler:^(NSMutableArray *array, NSUInteger nextPage, NSError *error) {
                             if (error) {
                                 [self handleError:error];
                             } else {
                                 [self setNextPage:nextPage forSection:section];
                                 [self.issues addObjectsFromArray:array];
                                 [self cacheIssuesHeight];
                                 [self.tableView reloadData];
                             }
                         }];
}

#pragma mark - initialization

- (id)initWithRepository:(NSString *)repository {
    if (self = [super initWithStyle:UITableViewStyleGrouped]) {
        self.repository = repository;
    }
    return self;
}

#pragma mark - Memory management

- (void)dealloc {
    [_repository release];
    
    [super dealloc];
}

@end
