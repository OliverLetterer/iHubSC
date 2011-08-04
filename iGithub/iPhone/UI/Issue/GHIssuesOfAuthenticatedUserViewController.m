//
//  GHIssuesOfAuthenticatedUserViewController.m
//  iGithub
//
//  Created by Oliver Letterer on 03.08.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHIssuesOfAuthenticatedUserViewController.h"
#import "GHDescriptionTableViewCell.h"
#import "GHIssueViewController.h"
#import "GHSearchFieldTableViewCell.h"
#import "UIColor+GithubUI.h"
#import "NSUserDefaults+Settings.h"

#define kUITableViewSectionSearch                   0
#define kUITableViewSectionAssignedIssues           1

#define kUITableViewNumberOfSections                2

@implementation GHIssuesOfAuthenticatedUserViewController
@synthesize assignedIssues=_assignedIssues, searchString=_searchString, filteresIssues=_filteresIssues;

#pragma mark - setters and getters

- (void)setAssignedIssues:(NSMutableArray *)assignedIssues {
    if (assignedIssues != _assignedIssues) {
        _assignedIssues = assignedIssues;
        
        [self cacheAssignedIssuesHeight];
        NSUInteger count = _assignedIssues.count;
        if (count > 0 && [NSUserDefaults standardUserDefaults].showIssuesBadge) {
            self.tabBarItem.badgeValue = [NSString stringWithFormat:@"%u", count];
        } else {
            self.tabBarItem.badgeValue = nil;
        }
        if (self.isViewLoaded) {
            [self.tableView reloadData];
        }
    }
}

- (void)setSearchString:(NSString *)searchString {
    _searchString = [searchString copy];
    
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:_assignedIssues.count];
    [_assignedIssues enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        GHAPIIssueV3 *isssue = obj;
        if ([isssue matchedString:searchString]) {
            [array addObject:isssue];
        }
    }];
    
    self.filteresIssues = array;
}

#pragma mark - Initialization

- (id)init {
    if ((self = [super initWithStyle:UITableViewStylePlain])) {
        // Custom initialization
        self.pullToReleaseEnabled = YES;
        self.reloadDataIfNewUserGotAuthenticated = YES;
        
        self.tabBarItem = [[UITabBarItem alloc] initWithTitle:nil image:[UIImage imageNamed:@"162-receipt.png"] tag:0];
        self.title = NSLocalizedString(@"My Issues", @"");
        
        [self pullToReleaseTableViewReloadData];
    }
    return self;
}

#pragma mark - Pull to release

- (void)pullToReleaseTableViewReloadData {
    [super pullToReleaseTableViewReloadData];
    
    [GHAPIIssueV3 allIssuesOfAuthenticatedUserWithCompletionHandler:^(NSMutableArray *issues, NSError *error) {
        if (error) {
            [self handleError:error];
        } else {
            self.assignedIssues = issues;
            [self pullToReleaseTableViewDidReloadData];
        }
    }];
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    _canTrackSearchBarState = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (_isSearchBarActive) {
        [_searchBar becomeFirstResponder];
        _searchBar.text = self.searchString;
    }
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    _searchBar = nil;
    _mySearchDisplayController = nil;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    _canTrackSearchBarState = NO;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView == _mySearchDisplayController.searchResultsTableView) {
        return 1;
    }
    
    if (!_assignedIssues) {
        return 0;
    }
    // Return the number of section.
    return kUITableViewNumberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == _mySearchDisplayController.searchResultsTableView) {
        return _filteresIssues.count;
    }
    
    if (section == kUITableViewSectionAssignedIssues) {
        return _assignedIssues.count;
    } else if (section == kUITableViewSectionSearch) {
        return 1;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == _mySearchDisplayController.searchResultsTableView) {
        static NSString *CellIdentifier = @"GHFeedItemWithDescriptionTableViewCell";
        
        GHDescriptionTableViewCell *cell = (GHDescriptionTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[GHDescriptionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        GHAPIIssueV3 *issue = [_filteresIssues objectAtIndex:indexPath.row];
        
        cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Issue %@", @""), issue.number];
        
        [self updateImageView:cell.imageView atIndexPath:indexPath withAvatarURLString:issue.user.avatarURL];
        
        cell.detailTextLabel.text = [NSString stringWithFormat:@"by %@ %@", issue.user.login, [NSString stringWithFormat:NSLocalizedString(@"%@ ago", @""), issue.createdAt.prettyTimeIntervalSinceNow]];
        ;
        
        cell.descriptionLabel.text = [self descriptionForAssignedIssue:issue];
        
        return cell;
    }
    
    if (indexPath.section == kUITableViewSectionAssignedIssues) {
        static NSString *CellIdentifier = @"GHFeedItemWithDescriptionTableViewCell";
        
        GHDescriptionTableViewCell *cell = (GHDescriptionTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[GHDescriptionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        GHAPIIssueV3 *issue = [self.assignedIssues objectAtIndex:indexPath.row];
        
        cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Issue %@", @""), issue.number];
        
        [self updateImageView:cell.imageView atIndexPath:indexPath withAvatarURLString:issue.user.avatarURL];
        
        cell.detailTextLabel.text = [NSString stringWithFormat:@"by %@ %@", issue.user.login, [NSString stringWithFormat:NSLocalizedString(@"%@ ago", @""), issue.createdAt.prettyTimeIntervalSinceNow]];
        ;
        
        cell.descriptionLabel.text = [self descriptionForAssignedIssue:issue];
        
        return cell;
    } else if (indexPath.section == kUITableViewSectionSearch) {
        if (indexPath.row == 0) {
            static NSString *CellIdentifier = @"GHSearchFieldTableViewCell";
            
            GHSearchFieldTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[GHSearchFieldTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            }
            
            if (!_mySearchDisplayController) {
                _mySearchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:cell.searchBar contentsController:self];
                _mySearchDisplayController.delegate = self;
                _mySearchDisplayController.searchResultsDataSource = self;
                _mySearchDisplayController.searchResultsDelegate = self;
                
                _searchBar = cell.searchBar;
                _searchBar.delegate = self;
            }
            
            cell.searchBar.tintColor = [UIColor defaultNavigationBarTintColor];
            
            return cell;
        }
    }
    
    return self.dummyCell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == _mySearchDisplayController.searchResultsTableView) {
        GHAPIIssueV3 *issue = [_filteresIssues objectAtIndex:indexPath.row];
        
        GHIssueViewController *viewController = [[GHIssueViewController alloc] initWithRepository:issue.repository issueNumber:issue.number];
        [self.navigationController pushViewController:viewController animated:YES];
    }
    
    if (indexPath.section == kUITableViewSectionAssignedIssues) {
        GHAPIIssueV3 *issue = [self.assignedIssues objectAtIndex:indexPath.row];
        
        GHIssueViewController *viewController = [[GHIssueViewController alloc] initWithRepository:issue.repository issueNumber:issue.number];
        [self.navigationController pushViewController:viewController animated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == _mySearchDisplayController.searchResultsTableView) {
        GHAPIIssueV3 *issue = [_filteresIssues objectAtIndex:indexPath.row];
        
        return [GHDescriptionTableViewCell heightWithContent:[self descriptionForAssignedIssue:issue]];
    }
    
    if (indexPath.section == kUITableViewSectionAssignedIssues) {
        return [self cachedHeightForRowAtIndexPath:indexPath];
    } else if (indexPath.section == kUITableViewSectionSearch) {
        return kGHSearchFieldTableViewCellHeight;
    }
    return 44.0f;
}

#pragma mark - height caching

- (NSString *)descriptionForAssignedIssue:(GHAPIIssueV3 *)issue {
    return [NSString stringWithFormat:NSLocalizedString(@"on %@\n\n%@", @""), issue.repository, issue.title];
}

- (void)cacheAssignedIssuesHeight {
    [self.assignedIssues enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        GHAPIIssueV3 *issue = obj;
        [self cacheHeight:[GHDescriptionTableViewCell heightWithContent:[self descriptionForAssignedIssue:issue]] forRowAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:kUITableViewSectionAssignedIssues] ];
    }];
}

#pragma mark - UISearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    _isSearchBarActive = YES;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    if (_canTrackSearchBarState) {
        _isSearchBarActive = NO;
    }
}

#pragma mark - UISearchDisplayDelegate

- (void)searchDisplayController:(UISearchDisplayController *)controller didLoadSearchResultsTableView:(UITableView *)tableView {
    tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"GHBackgroundImage.png"] ];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    self.searchString = searchString;
    return YES;
}

#pragma mark - Keyed Archiving

- (void)encodeWithCoder:(NSCoder *)encoder {
    [super encodeWithCoder:encoder];
    [encoder encodeObject:_assignedIssues forKey:@"assignedIssues"];
    [encoder encodeObject:_searchString forKey:@"searchString"];
    [encoder encodeObject:_filteresIssues forKey:@"filteresIssues"];
    [encoder encodeBool:_isSearchBarActive forKey:@"isSearchBarActive"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super initWithCoder:decoder])) {
        self.tabBarItem = [[UITabBarItem alloc] initWithTitle:nil image:[UIImage imageNamed:@"162-receipt.png"] tag:0];
        self.title = NSLocalizedString(@"My Issues", @"");
        
        self.assignedIssues = [decoder decodeObjectForKey:@"assignedIssues"];
        _searchString = [decoder decodeObjectForKey:@"searchString"];
        _filteresIssues = [decoder decodeObjectForKey:@"filteresIssues"];
        _isSearchBarActive = [decoder decodeBoolForKey:@"isSearchBarActive"];
    }
    return self;
}

@end
