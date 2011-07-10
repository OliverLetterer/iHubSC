//
//  GHPSearchViewController.m
//  iGithub
//
//  Created by Oliver Letterer on 09.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHPSearchViewController.h"
#import "GHPSearchBarTableViewCell.h"
#import "GHPUserTableViewCell.h"
#import "GHPUserViewController.h"
#import "GHPRepositoryTableViewCell.h"
#import "GHPRepositoryViewController.h"

#define kUIButtonTitleRepositories      NSLocalizedString(@"Repositories", @"")
#define kUIButtonTitleUsers             NSLocalizedString(@"Users", @"")

@implementation GHPSearchViewController

@synthesize dataType=_dataType, dataArray=_dataArray;
@synthesize searchScopeTableViewCell=_searchScopeTableViewCell;

#pragma mark - setters and getters

- (void)setDataArray:(NSMutableArray *)dataArray withDataType:(GHPSearchViewControllerDataType)dataType {
    if (dataArray != _dataArray && _dataType != dataType) {
        _dataType = dataType;
        [_dataArray release], _dataArray = [dataArray retain];
        
        [self.searchDisplayController.searchResultsTableView reloadData];
    }
}

#pragma mark - Initialization

- (id)init {
    if ((self = [super initWithStyle:UITableViewStyleGrouped])) {
        // Custom initialization
        _nextSearchType = GHPSearchViewControllerDataTypeRepositories;
    }
    return self;
}

#pragma mark - Memory management

- (void)dealloc {
    [_dataArray release];
    [_searchScopeTableViewCell release];
    [_mySearchDisplayController release];
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidUnload {
    [super viewDidUnload];
    
    [_mySearchDisplayController release], _mySearchDisplayController = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
	return YES;
}

#pragma mark - Downloading

- (void)downloadDataBasedOnSearchString {
    [self setDataArray:nil 
          withDataType:GHPSearchViewControllerDataTypeNone];
    
    NSString *searchString = self.searchDisplayController.searchBar.text;
    if (_nextSearchType == GHPSearchViewControllerDataTypeRepositories) {
        [GHRepository searchRepositoriesWithSearchString:searchString 
                                       completionHandler:^(NSArray *repos, NSError *error) {
                                           if (error) {
                                               [self handleError:error];
                                           } else {
                                               [self setDataArray:[[repos mutableCopy] autorelease] 
                                                     withDataType:GHPSearchViewControllerDataTypeRepositories];
                                           }
                                       }];
    } else if (_nextSearchType == GHPSearchViewControllerDataTypeUsers) {
        [GHUser searchUsersWithSearchString:searchString 
                          completionHandler:^(NSArray *users, NSError *error) {
                              if (error) {
                                  [self handleError:error];
                              } else {
                                  [self setDataArray:[[users mutableCopy] autorelease] 
                                        withDataType:GHPSearchViewControllerDataTypeUsers];
                              }
                          }];
    } else {
        [self setDataArray:nil 
              withDataType:GHPSearchViewControllerDataTypeNone];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    if (tableView == self.tableView) {
        return 1;
    } else if (tableView == self.searchDisplayController.searchResultsTableView) {
        NSInteger count = 1;
        if (self.dataType != GHPSearchViewControllerDataTypeNone) {
            count++;
        }
        return count;
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.tableView) {
        if (section == 0) {
            return 1;
        }
    } else if (tableView == self.searchDisplayController.searchResultsTableView) {
        if (section == 0) {
            return 1;
        } else if (section == 1) {
            return self.dataArray.count;
        }
    }
    // Return the number of rows in the section.
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.tableView) {
        if (indexPath.section == 0) {
            if (indexPath.row == 0) {
                static NSString *CellIdentifier = @"GHPSearchBarTableViewCell";
                
                GHPSearchBarTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                if (cell == nil) {
                    cell = [[[GHPSearchBarTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
                }
                
                [self setupDefaultTableViewCell:cell forRowAtIndexPath:indexPath];
                cell.searchBar.delegate = self;
                
                if (!self.searchDisplayController) {
                    _mySearchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:cell.searchBar
                                                                                                           contentsController:self];
                    _mySearchDisplayController.searchResultsDelegate = self;
                    _mySearchDisplayController.searchResultsDataSource = self;
                    _mySearchDisplayController.delegate = self;
                }
                
                return cell;
            }
        }
    } else if (tableView == self.searchDisplayController.searchResultsTableView) {
        if (indexPath.section == 0) {
            if (indexPath.row == 0) {
                static NSString *CellIdentifier = @"GHPSearchScopeTableViewCell";
                
                GHPSearchScopeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                if (cell == nil) {
                    NSArray *buttonTitles = [NSArray arrayWithObjects:kUIButtonTitleRepositories, kUIButtonTitleUsers, nil];
                    cell = [[[GHPSearchScopeTableViewCell alloc] initWithButtonTitles:buttonTitles reuseIdentifier:CellIdentifier] autorelease];
                }
                [self setupDefaultTableViewCell:cell forRowAtIndexPath:indexPath];
                
                self.searchScopeTableViewCell = cell;
                cell.delegate = self;
                
                return cell;
            }
        } else if (indexPath.section == 1) {
            // got data
            if (_dataType == GHPSearchViewControllerDataTypeUsers) {
                static NSString *CellIdentifier = @"GHPUserTableViewCell";
                
                GHPUserTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                if (cell == nil) {
                    cell = [[[GHPUserTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
                }
                [self setupDefaultTableViewCell:cell forRowAtIndexPath:indexPath];
                
                GHUser *user = [self.dataArray objectAtIndex:indexPath.row];
                
                [self updateImageView:cell.imageView inTableView:tableView atIndexPath:indexPath withGravatarID:user.gravatarID];
                cell.textLabel.text = user.login;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                
                return cell;
            } else if (_dataType == GHPSearchViewControllerDataTypeRepositories) {
                static NSString *CellIdentifier = @"GHPRepositoryTableViewCell";
                
                GHPRepositoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                
                if (cell == nil) {
                    cell = [[[GHPRepositoryTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
                }
                
                GHRepository *repository = [self.dataArray objectAtIndex:indexPath.row];
                
                cell.textLabel.text = [NSString stringWithFormat:@"%@/%@", repository.owner, repository.name];
                cell.detailTextLabel.text = repository.desctiptionRepo;
                
                if ([repository.private boolValue]) {
                    cell.imageView.image = [UIImage imageNamed:@"GHPrivateRepositoryIcon.png"];
                } else {
                    cell.imageView.image = [UIImage imageNamed:@"GHPublicRepositoryIcon.png"];
                }
                
                [self setupDefaultTableViewCell:cell forRowAtIndexPath:indexPath];
                
                return cell;
            }
        }
    }
    
    return self.dummyCell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        if (indexPath.section == 1) {
            // got data
            if (_dataType == GHPSearchViewControllerDataTypeUsers) {
                return GHPUserTableViewCellHeight;
            } else if (_dataType == GHPSearchViewControllerDataTypeRepositories) {
                GHRepository *repository = [self.dataArray objectAtIndex:indexPath.row];
                return [GHPRepositoryTableViewCell heightWithContent:repository.desctiptionRepo];
            }
        }
    }
    return UITableViewAutomaticDimension;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIViewController *viewController = nil;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        if (indexPath.section == 1) {
            // got data
            if (_dataType == GHPSearchViewControllerDataTypeUsers) {
                GHUser *user = [self.dataArray objectAtIndex:indexPath.row];
                viewController = [[[GHPUserViewController alloc] initWithUsername:user.login] autorelease];
            } else if (_dataType == GHPSearchViewControllerDataTypeRepositories) {
                GHRepository *repository = [self.dataArray objectAtIndex:indexPath.row];
                NSString *repositoryString = [NSString stringWithFormat:@"%@/%@", repository.owner, repository.name];
                viewController = [[[GHPRepositoryViewController alloc] initWithRepositoryString:repositoryString] autorelease];
            }
        }
    }
    
    if (viewController) {
        [self.advancedNavigationController pushViewController:viewController afterViewController:self];
    } else {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
}

#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    if (![searchBar.text isEqualToString:@""] && searchBar.text) {
        [self downloadDataBasedOnSearchString];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
#warning pop viewControllers that are on the right
}

#pragma mark - UISearchDisplayDelegate

- (void)searchDisplayController:(UISearchDisplayController *)controller didLoadSearchResultsTableView:(UITableView *)tableView {
    [tableView initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    tableView.backgroundColor = self.tableView.backgroundColor;
    tableView.backgroundView = nil;
}

#pragma mark - GHPSearchScopeTableViewCellDelegate

- (void)searchScopeTableViewCell:(GHPSearchScopeTableViewCell *)searchScopeTableViewCell didSelectButtonAtIndex:(NSUInteger)index {
    NSString *title = [searchScopeTableViewCell titleForButtonAtIndex:index];
    
    if ([title isEqualToString:kUIButtonTitleRepositories]) {
        _nextSearchType = GHPSearchViewControllerDataTypeRepositories;
    } else if ([title isEqualToString:kUIButtonTitleUsers]) {
        _nextSearchType = GHPSearchViewControllerDataTypeUsers;
    }
    
    
    if (!self.searchDisplayController.searchBar.isFirstResponder) {
        [self downloadDataBasedOnSearchString];
    }
}

@end
