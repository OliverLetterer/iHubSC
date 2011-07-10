//
//  GHPLabelViewController.m
//  iGithub
//
//  Created by Oliver Letterer on 09.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHPLabelViewController.h"
#import "GHPImageDetailTableViewCell.h"
#import "GHPIssueViewController.h"

#define kUITableViewControllerSectionInfoOpenIssues     0
#define kUITableViewControllerSectionInfoClosedIssues   1

#define kUITableViewNumberOfSections                    2

@implementation GHPLabelViewController

#pragma mark - View lifecycle

- (id)initWithRepository:(NSString *)repository label:(GHAPILabelV3 *)label {
    if (self = [super initWithStyle:UITableViewStyleGrouped]) {
        self.repositoryString = repository;
        self.label = label;
    }
    return self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
	return YES;
}

- (NSString *)contentForIssue:(GHAPIIssueV3 *)issue {
    return [NSString stringWithFormat:NSLocalizedString(@"Issue %@ - %@", @""), issue.number, issue.title];
}

#pragma mark - UIExpandableTableViewDatasource

- (BOOL)tableView:(UIExpandableTableView *)tableView canExpandSection:(NSInteger)section {
    return section == kUITableViewControllerSectionInfoOpenIssues || section == kUITableViewControllerSectionInfoClosedIssues;
}

- (BOOL)tableView:(UIExpandableTableView *)tableView needsToDownloadDataForExpandableSection:(NSInteger)section {
    if (section == kUITableViewControllerSectionInfoOpenIssues) {
        return self.openIssues == nil;
    } else if (section == kUITableViewControllerSectionInfoClosedIssues) {
        return self.closedIssues == nil;
    }
    return NO;
}

- (UITableViewCell<UIExpandingTableViewCell> *)tableView:(UIExpandableTableView *)tableView expandingCellForSection:(NSInteger)section {
    GHPCollapsingAndSpinningTableViewCell *cell = [self defaultPadCollapsingAndSpinningTableViewCellForSection:section];
    
    if (section == kUITableViewControllerSectionInfoOpenIssues) {
        cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Open Issues", @"")];
    } else if (section == kUITableViewControllerSectionInfoClosedIssues) {
        cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Closed Issues", @"")];
    }
    
    return cell;
}

#pragma mark - pagination

- (void)downloadDataForPage:(NSUInteger)page inSection:(NSUInteger)section {
    if (section == kUITableViewControllerSectionInfoOpenIssues) {
        [GHAPIIssueV3 issuesOnRepository:self.repositoryString milestone:nil 
                                  labels:[NSArray arrayWithObject:self.label.name] 
                                   state:kGHAPIIssueStateV3Open page:page 
                       completionHandler:^(NSMutableArray *array, NSUInteger nextPage, NSError *error) {
                           if (error) {
                               [self handleError:error];
                           } else {
                               [self.openIssues addObjectsFromArray:array];
                               [self cacheHeightForOpenIssuesArray];
                               [self setNextPage:nextPage forSection:section];
                               [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:section] 
                                             withRowAnimation:UITableViewRowAnimationAutomatic];
                           }
                       }];
    } else if (section == kUITableViewControllerSectionInfoClosedIssues) {
        [GHAPIIssueV3 issuesOnRepository:self.repositoryString milestone:nil 
                                  labels:[NSArray arrayWithObject:self.label.name] 
                                   state:kGHAPIIssueStateV3Closed page:page 
                       completionHandler:^(NSMutableArray *array, NSUInteger nextPage, NSError *error) {
                           if (error) {
                               [self handleError:error];
                           } else {
                               [self.closedIssues addObjectsFromArray:array];
                               [self cacheHeightForClosedIssuesArray];
                               [self setNextPage:nextPage forSection:section];
                               [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:section] 
                                             withRowAnimation:UITableViewRowAnimationAutomatic];
                           }
                       }];
    }
}

#pragma mark - UIExpandableTableViewDelegate

- (void)tableView:(UIExpandableTableView *)tableView downloadDataForExpandableSection:(NSInteger)section {
    if (section == kUITableViewControllerSectionInfoOpenIssues) {
        [GHAPIIssueV3 issuesOnRepository:self.repositoryString milestone:nil 
                                  labels:[NSArray arrayWithObject:self.label.name] 
                                   state:kGHAPIIssueStateV3Open page:1 
                       completionHandler:^(NSMutableArray *array, NSUInteger nextPage, NSError *error) {
                           if (error) {
                               [self handleError:error];
                               [tableView cancelDownloadInSection:section];
                           } else {
                               self.openIssues = array;
                               [self cacheHeightForOpenIssuesArray];
                               [self setNextPage:nextPage forSection:section];
                               [tableView expandSection:section animated:YES];
                           }
                       }];
    } else if (section == kUITableViewControllerSectionInfoClosedIssues) {
        [GHAPIIssueV3 issuesOnRepository:self.repositoryString milestone:nil 
                                  labels:[NSArray arrayWithObject:self.label.name] 
                                   state:kGHAPIIssueStateV3Closed page:1 
                       completionHandler:^(NSMutableArray *array, NSUInteger nextPage, NSError *error) {
                           if (error) {
                               [self handleError:error];
                               [tableView cancelDownloadInSection:section];
                           } else {
                               self.closedIssues = array;
                               [self cacheHeightForClosedIssuesArray];
                               [self setNextPage:nextPage forSection:section];
                               [tableView expandSection:section animated:YES];
                           }
                       }];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (!self.label) {
        return 0;
    }
    return kUITableViewNumberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == kUITableViewControllerSectionInfoOpenIssues) {
        return self.openIssues.count + 1;
    } else if (section == kUITableViewControllerSectionInfoClosedIssues) {
        return self.closedIssues.count + 1;
    }
    
    // Return the number of rows in the section.
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"GHPImageDetailTableViewCell";
    
    GHPImageDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[GHPImageDetailTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    [self setupDefaultTableViewCell:cell forRowAtIndexPath:indexPath];
    
    GHAPIIssueV3 *issue = nil;
    
    if (indexPath.section == kUITableViewControllerSectionInfoOpenIssues) {
        if (indexPath.row > 0 && indexPath.row <= [self.openIssues count]) {
            issue = [self.openIssues objectAtIndex:indexPath.row - 1];
        }
    } else if (indexPath.section == kUITableViewControllerSectionInfoClosedIssues) {
        if (indexPath.row > 0 && indexPath.row <= [self.closedIssues count]) {
            issue = [self.closedIssues objectAtIndex:indexPath.row - 1];
        }
    }
    
    [self updateImageView:cell.imageView atIndexPath:indexPath withGravatarID:issue.user.gravatarID];
    cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@ (%@ ago)", @""), issue.user.login, issue.createdAt.prettyTimeIntervalSinceNow];
    cell.detailTextLabel.text = [self contentForIssue:issue];
    
    return cell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == kUITableViewControllerSectionInfoOpenIssues && indexPath.row > 0) {
        return [self cachedHeightForRowAtIndexPath:indexPath];
    } else if (indexPath.section == kUITableViewControllerSectionInfoClosedIssues && indexPath.row > 0) {
        return [self cachedHeightForRowAtIndexPath:indexPath];
    }
    return UITableViewAutomaticDimension;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIViewController *viewController = nil;
    
    if (indexPath.section == kUITableViewControllerSectionInfoOpenIssues && indexPath.row > 0) {
        GHAPIIssueV3 *issue = [self.openIssues objectAtIndex:indexPath.row - 1];
        viewController = [[[GHPIssueViewController alloc] initWithIssueNumber:issue.number onRepository:self.repositoryString] autorelease];
    } else if (indexPath.section == kUITableViewControllerSectionInfoClosedIssues && indexPath.row > 0) {
        GHAPIIssueV3 *issue = [self.closedIssues objectAtIndex:indexPath.row - 1];
        viewController = [[[GHPIssueViewController alloc] initWithIssueNumber:issue.number onRepository:self.repositoryString] autorelease];
    }
    
    if (viewController) {
        [self.advancedNavigationController pushViewController:viewController afterViewController:self];
    } else {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
}

#pragma mark - Height Caching

- (void)cacheHeightForOpenIssuesArray {
    NSInteger i = 1;
    for (GHAPIIssueV3 *issue in self.openIssues) {
        [self cacheHeight:[GHPImageDetailTableViewCell heightWithContent:[self contentForIssue:issue]] 
        forRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:kUITableViewControllerSectionInfoOpenIssues] ];
        i++;
    }
}

- (void)cacheHeightForClosedIssuesArray {
    NSInteger i = 1;
    for (GHAPIIssueV3 *issue in self.closedIssues) {
        [self cacheHeight:[GHPImageDetailTableViewCell heightWithContent:[self contentForIssue:issue]] 
        forRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:kUITableViewControllerSectionInfoClosedIssues] ];
        i++;
    }
}
@end
