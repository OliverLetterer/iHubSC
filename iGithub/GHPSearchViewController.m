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
@synthesize searchString=_searchString, searchBar=_searchBar;

#pragma mark - setters and getters

- (void)setDataArray:(NSMutableArray *)dataArray withDataType:(GHPSearchViewControllerDataType)dataType {
    if (dataArray != _dataArray && _dataType != dataType) {
        _dataType = dataType;
        _dataArray = dataArray;
        
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


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidUnload {
    [super viewDidUnload];
    
    _mySearchDisplayController = nil;
    _searchBar = nil;
}

- (void)_updateSearchBar {
    if (self.searchString) {
        self.searchBar.text = self.searchString;
    }
    
    if (_isSearchBarActive) {
        [self.searchBar becomeFirstResponder];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self performSelector:@selector(_updateSearchBar) withObject:nil afterDelay:0.01];
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
                                               [self setDataArray:[repos mutableCopy] 
                                                     withDataType:GHPSearchViewControllerDataTypeRepositories];
                                           }
                                       }];
    } else if (_nextSearchType == GHPSearchViewControllerDataTypeUsers) {
        [GHUser searchUsersWithSearchString:searchString 
                          completionHandler:^(NSArray *users, NSError *error) {
                              if (error) {
                                  [self handleError:error];
                              } else {
                                  [self setDataArray:[users mutableCopy] 
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
                    cell = [[GHPSearchBarTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                }
                
                self.searchBar = cell.searchBar;
                
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
                    cell = [[GHPSearchScopeTableViewCell alloc] initWithButtonTitles:buttonTitles reuseIdentifier:CellIdentifier];
                }
                [self setupDefaultTableViewCell:cell inTableView:tableView forRowAtIndexPath:indexPath];
                
                self.searchScopeTableViewCell = cell;
                switch (_nextSearchType) {
                    case GHPSearchViewControllerDataTypeRepositories:
                        [cell selectButtonAtIndex:0];
                        break;
                    case GHPSearchViewControllerDataTypeUsers:
                        [cell selectButtonAtIndex:1];
                        break;
                    default:
                        break;
                }
                cell.delegate = self;
                
                return cell;
            }
        } else if (indexPath.section == 1) {
            // got data
            if (_dataType == GHPSearchViewControllerDataTypeUsers) {
                static NSString *CellIdentifier = @"GHPUserTableViewCell";
                
                GHPUserTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                if (cell == nil) {
                    cell = [[GHPUserTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                }
                [self setupDefaultTableViewCell:cell inTableView:tableView forRowAtIndexPath:indexPath];
                
                GHUser *user = [self.dataArray objectAtIndex:indexPath.row];
                
                [self updateImageView:cell.imageView inTableView:tableView atIndexPath:indexPath withGravatarID:user.gravatarID];
                cell.textLabel.text = user.login;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                
                return cell;
            } else if (_dataType == GHPSearchViewControllerDataTypeRepositories) {
                static NSString *CellIdentifier = @"GHPRepositoryTableViewCell";
                
                GHPRepositoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                
                if (cell == nil) {
                    cell = [[GHPRepositoryTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
                }
                [self setupDefaultTableViewCell:cell inTableView:tableView forRowAtIndexPath:indexPath];
                
                GHRepository *repository = [self.dataArray objectAtIndex:indexPath.row];
                
                cell.textLabel.text = [NSString stringWithFormat:@"%@/%@", repository.owner, repository.name];
                cell.detailTextLabel.text = repository.desctiptionRepo;
                
                if ([repository.private boolValue]) {
                    cell.imageView.image = [UIImage imageNamed:@"GHPrivateRepositoryIcon.png"];
                } else {
                    cell.imageView.image = [UIImage imageNamed:@"GHPublicRepositoryIcon.png"];
                }
                
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
                viewController = [[GHPUserViewController alloc] initWithUsername:user.login];
            } else if (_dataType == GHPSearchViewControllerDataTypeRepositories) {
                GHRepository *repository = [self.dataArray objectAtIndex:indexPath.row];
                NSString *repositoryString = [NSString stringWithFormat:@"%@/%@", repository.owner, repository.name];
                viewController = [[GHPRepositoryViewController alloc] initWithRepositoryString:repositoryString];
            }
        }
    }
    
    if (viewController) {
        [self.advancedNavigationController pushViewController:viewController afterViewController:self animated:YES];
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
    [self setDataArray:nil withDataType:GHPSearchViewControllerDataTypeNone];
    [self.advancedNavigationController popViewControllersToViewController:self animated:YES];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    self.searchString = searchText;
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    _isSearchBarActive = YES;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    _isSearchBarActive = NO;
}

#pragma mark - UISearchDisplayDelegate

- (void)searchDisplayController:(UISearchDisplayController *)controller didLoadSearchResultsTableView:(UITableView *)tableView {
    [tableView initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    tableView.backgroundColor = self.tableView.backgroundColor;
    tableView.backgroundView = nil;
}

#pragma mark - GHPSearchScopeTableViewCellDelegate

- (void)searchScopeTableViewCell:(GHPSearchScopeTableViewCell *)searchScopeTableViewCell didSelectButtonAtIndex:(NSUInteger)index {
    [self.advancedNavigationController popViewControllersToViewController:self animated:YES];
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

#pragma mark - Keyed Archiving

- (void)encodeWithCoder:(NSCoder *)encoder {
    [super encodeWithCoder:encoder];
    [encoder encodeInt:_dataType forKey:@"dataType"];
    [encoder encodeObject:_dataArray forKey:@"dataArray"];
    [encoder encodeInt:_nextSearchType forKey:@"nextSearchType"];
    [encoder encodeObject:_searchString forKey:@"searchString"];
    [encoder encodeBool:_isSearchBarActive forKey:@"isSearchBarActive"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super initWithCoder:decoder])) {
        _dataType = [decoder decodeIntForKey:@"dataType"];
        _dataArray = [decoder decodeObjectForKey:@"dataArray"];
        _nextSearchType = [decoder decodeIntForKey:@"nextSearchType"];
        _searchString = [decoder decodeObjectForKey:@"searchString"];
        _isSearchBarActive = [decoder decodeBoolForKey:@"isSearchBarActive"];
    }
    return self;
}

@end
