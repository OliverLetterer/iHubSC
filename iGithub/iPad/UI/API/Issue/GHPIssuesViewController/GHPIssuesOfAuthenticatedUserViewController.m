//
//  GHPIssuesOfAuthenticatedUserViewController.m
//  iGithub
//
//  Created by Oliver Letterer on 14.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHPIssuesOfAuthenticatedUserViewController.h"
#import "GHPImageDetailTableViewCell.h"
#import "GHPIssueViewController.h"
#import "GHPSearchBarTableViewCell.h"

@implementation GHPIssuesOfAuthenticatedUserViewController
@synthesize searchString=_searchString, filteresIssues=_filteresIssues;

- (NSString *)descriptionStringForIssue:(GHAPIIssueV3 *)issue {
    return [NSString stringWithFormat:NSLocalizedString(@"Issue %@ on %@\n\n%@", @""), issue.number, issue.repository, issue.title];
}

#pragma mark - setters and getters

- (void)setSearchString:(NSString *)searchString {
    _searchString = [searchString copy];
    
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:self.dataArray.count];
    [self.dataArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        GHAPIIssueV3 *isssue = obj;
        if ([isssue matchedString:searchString]) {
            [array addObject:isssue];
        }
    }];
    
    self.filteresIssues = array;
}

#pragma mark - Notifications
#warning contains issue - update

- (void)issueCreationNotificationCallback:(NSNotification *)notification {
    GHAPIIssueV3 *issue = [notification.userInfo objectForKey:GHAPIV3NotificationUserDictionaryIssueKey];
    BOOL changed = NO;
    
    if ([issue.assignee.login isEqualToString:[GHAPIAuthenticationManager sharedInstance].authenticatedUser.login] && [issue.state isEqualToString:kGHAPIIssueStateV3Open]) {
        // issue is open and belongs to us ;)
        [self.dataArray insertObject:issue atIndex:0];
        
        if ([issue matchedString:self.searchString]) {
            [self.filteresIssues insertObject:issue atIndex:0];
        }
        
        changed = YES;
    }
    
    if (changed) {
        [self cacheDataArrayHeights];
        if (self.isViewLoaded) {
            [self.tableView reloadDataAndResetExpansionStates:NO];
            [_mySearchDisplayController.searchResultsTableView reloadData];
        }
    }
}

- (void)issueChangedNotificationCallback:(NSNotification *)notification {
    GHAPIIssueV3 *issue = [notification.userInfo objectForKey:GHAPIV3NotificationUserDictionaryIssueKey];
    BOOL changed = NO;
    
    if ([issue.assignee.login isEqualToString:[GHAPIAuthenticationManager sharedInstance].authenticatedUser.login]) {
        // issue belongs here
        if ([issue.state isEqualToString:kGHAPIIssueStateV3Open]) {
            // issue is open
            if (![self.dataArray containsObject:issue]) {
                [self.dataArray insertObject:issue atIndex:0];
                changed = YES;
            }
        } else {
            // issue is closed
            if ([self.dataArray containsObject:issue]) {
                [self.dataArray removeObject:issue];
                changed = YES;
            }
        }
    } else {
        if ([self.dataArray containsObject:issue]) {
            [self.dataArray removeObject:issue];
            changed = YES;
        }
    }
    
    if (changed) {
        [self cacheDataArrayHeights];
        if (self.isViewLoaded) {
            [self.tableView reloadDataAndResetExpansionStates:NO];
            [_mySearchDisplayController.searchResultsTableView reloadData];
        }
    }
}

#pragma mark - Initialization

- (id)init {
    if (self = [super initWithStyle:UITableViewStyleGrouped]) {
        self.isDownloadingEssentialData = YES;
        [GHAPIIssueV3 allIssuesOfAuthenticatedUserWithCompletionHandler:^(NSMutableArray *issues, NSError *error) {
            self.isDownloadingEssentialData = NO;
            if (error) {
                [self handleError:error];
            } else {
                [self setDataArray:issues nextPage:GHAPIPaginationNextPageNotFound];
            }
        }];
    }
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidUnload {
    [super viewDidUnload];
    
    _mySearchDisplayController = nil;
    _searchBar = nil;
}

- (void)_updateSearchBar {
    if (self.searchString) {
        _searchBar.text = self.searchString;
    }
    
    if (_isSearchBarActive) {
        [_searchBar becomeFirstResponder];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self performSelector:@selector(_updateSearchBar) withObject:nil afterDelay:0.01];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView == _mySearchDisplayController.searchResultsTableView) {
        return 1;
    }
    
    // Return the number of section.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == _mySearchDisplayController.searchResultsTableView) {
        return _filteresIssues.count;
    }
    
    if (section == 0) {
        return 1;
    }
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == _mySearchDisplayController.searchResultsTableView) {
        static NSString *CellIdentifier = @"GHPImageDetailTableViewCell";
        
        GHPImageDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[GHPImageDetailTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        }
        [self setupDefaultTableViewCell:cell inTableView:tableView forRowAtIndexPath:indexPath];
        
        GHAPIIssueV3 *issue = [_filteresIssues objectAtIndex:indexPath.row];
        
        [self updateImageView:cell.imageView atIndexPath:indexPath withAvatarURLString:issue.user.avatarURL];
        cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@ (%@ ago)", @""), issue.user.login, issue.createdAt.prettyTimeIntervalSinceNow];
        cell.detailTextLabel.text = [self descriptionStringForIssue:issue];
        
        // Configure the cell...
        
        return cell;
    }
    
    if (indexPath.section == 0) {
        static NSString *CellIdentifier = @"GHPSearchBarTableViewCell";
        
        GHPSearchBarTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[GHPSearchBarTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        if (!_mySearchDisplayController) {
            _mySearchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:cell.searchBar contentsController:self];
            _mySearchDisplayController.delegate = self;
            _mySearchDisplayController.searchResultsDataSource = self;
            _mySearchDisplayController.searchResultsDelegate = self;
            
            _searchBar = cell.searchBar;
            _searchBar.delegate = self;
        }
        
        return cell;
    }
    
    
    static NSString *CellIdentifier = @"GHPImageDetailTableViewCell";
    
    GHPImageDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[GHPImageDetailTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    [self setupDefaultTableViewCell:cell forRowAtIndexPath:indexPath];
    
    GHAPIIssueV3 *issue = [self.dataArray objectAtIndex:indexPath.row];
    
    [self updateImageView:cell.imageView atIndexPath:indexPath withAvatarURLString:issue.user.avatarURL];
    cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@ (%@ ago)", @""), issue.user.login, issue.createdAt.prettyTimeIntervalSinceNow];
    cell.detailTextLabel.text = [self descriptionStringForIssue:issue];
    
    // Configure the cell...
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == _mySearchDisplayController.searchResultsTableView) {
        GHAPIIssueV3 *issue = [_filteresIssues objectAtIndex:indexPath.row];
        
        GHPIssueViewController *viewController = [[GHPIssueViewController alloc] initWithIssueNumber:issue.number onRepository:issue.repository];
        
        [self.advancedNavigationController pushViewController:viewController afterViewController:self animated:YES];
    }
    
    if (indexPath.section == 0) {
        return;
    }
    
    GHAPIIssueV3 *issue = [self.dataArray objectAtIndex:indexPath.row];
    
    GHPIssueViewController *viewController = [[GHPIssueViewController alloc] initWithIssueNumber:issue.number onRepository:issue.repository];
    
    [self.advancedNavigationController pushViewController:viewController afterViewController:self animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == _mySearchDisplayController.searchResultsTableView) {
        GHAPIIssueV3 *issue = [_filteresIssues objectAtIndex:indexPath.row];
        NSString *content = [self descriptionStringForIssue:issue];
        
        return [GHPImageDetailTableViewCell heightWithContent:content];
    }
    
    if (indexPath.section == 1) {
        GHAPIIssueV3 *issue = [self.dataArray objectAtIndex:indexPath.row];
        NSString *content = [self descriptionStringForIssue:issue];
        
        return [GHPImageDetailTableViewCell heightWithContent:content];
    } else if (indexPath.section == 0) {
        return 44.0f;
    }
    return UITableViewAutomaticDimension;
}

#pragma mark - UISearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    _isSearchBarActive = YES;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    _isSearchBarActive = NO;
}

#pragma mark - UISearchDisplayDelegate

- (void)searchDisplayController:(UISearchDisplayController *)controller didLoadSearchResultsTableView:(UITableView *)tableView {
    tableView = [tableView initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    tableView.backgroundColor = self.tableView.backgroundColor;
    tableView.backgroundView = nil;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    self.searchString = searchString;
    return YES;
}

#pragma mark - Keyed Archiving

- (void)encodeWithCoder:(NSCoder *)encoder {
    [super encodeWithCoder:encoder];
    [encoder encodeObject:_searchString forKey:@"searchString"];
    [encoder encodeBool:_isSearchBarActive forKey:@"isSearchBarActive"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super initWithCoder:decoder])) {
        _searchString = [decoder decodeObjectForKey:@"searchString"];
        _isSearchBarActive = [decoder decodeBoolForKey:@"isSearchBarActive"];
    }
    return self;
}

@end
