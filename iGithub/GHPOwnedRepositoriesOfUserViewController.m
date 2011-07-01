//
//  GHPOwnedRepositoriesOfUserViewController.m
//  iGithub
//
//  Created by Oliver Letterer on 01.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHPOwnedRepositoriesOfUserViewController.h"


@implementation GHPOwnedRepositoriesOfUserViewController

#pragma mark - setters and getters

- (void)setUsername:(NSString *)username {
    [super setUsername:username];
    
#warning this returns an error "Server Error" for the authenticated user, maybe iOS 5 bug, maybe GitHub
    [GHAPIRepositoryV3 repositoriesForUserNamed:username page:0 
                              completionHandler:^(NSMutableArray *array, NSUInteger nextPage, NSError *error) {
                                  if (error) {
                                      [self handleError:error];
                                  } else {
                                      self.repositories = array;
                                      [self cacheRepositoriesHeights];
                                      [self setNextPage:nextPage forSection:0];
                                      if (self.isViewLoaded) {
                                          [self.tableView reloadData];
                                      }
                                  }
                              }];
}

#pragma mark - Memory management

- (void)dealloc {
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
	return YES;
}

#pragma mark - Pagination

- (void)downloadDataForPage:(NSUInteger)page inSection:(NSUInteger)section {
    [GHAPIRepositoryV3 repositoriesForUserNamed:self.username 
                                           page:page 
                              completionHandler:^(NSMutableArray *array, NSUInteger nextPage, NSError *error) {
                                  if (error) {
                                      [self handleError:error];
                                  } else {
                                      [self.repositories addObjectsFromArray:array];
                                      [self setNextPage:nextPage forSection:section];
                                      [self cacheRepositoriesHeights];
                                      [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:section] 
                                                    withRowAnimation:UITableViewRowAnimationAutomatic];
                                  }
                              }];
}

@end