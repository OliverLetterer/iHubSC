//
//  GHPMilestoneViewController.m
//  iGithub
//
//  Created by Oliver Letterer on 06.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHPMilestoneViewController.h"
#import "GHPCollapsingAndSpinningTableViewCell.h"
#import "GHPImageDetailTableViewCell.h"
#import "GHPIssueViewController.h"

#define kUITableViewControllerSectionInfoOpenIssues     0
#define kUITableViewControllerSectionInfoClosedIssues   1

#define kUITableViewControllerNumberOfSections          2



@implementation GHPMilestoneViewController

@synthesize milestone=_milestone, repository=_repository, milestoneNumber=_milestoneNumber;
@synthesize openIssues=_openIssues, closedIssues=_closedIssues;

#pragma mark - Initialization

- (id)initWithRepository:(NSString *)repository milestoneNumber:(NSNumber *)milestoneNumber {
    if ((self = [super initWithStyle:UITableViewStyleGrouped])) {
        // Custom initialization
        self.milestoneNumber = milestoneNumber;
        self.repository = repository;
        [self downloadMilestoneData];
    }
    return self;
}

- (void)downloadMilestoneData {
    [GHAPIMilestoneV3 milestoneOnRepository:self.repository number:self.milestoneNumber 
                          completionHandler:^(GHAPIMilestoneV3 *milestone, NSError *error) {
                              if (error) {
                                  [self handleError:error];
                              } else {
                                  self.milestone = milestone;
                                  self.title = self.milestone.title;
                                  if ([self isViewLoaded]) {
                                      [self.tableView reloadData];
                                  }
                              }
                          }];
}

#pragma mark - Memory management

- (void)dealloc {
    [_repository release];
    [_milestoneNumber release];
    [_openIssues release];
    [_closedIssues release];
    [_milestone release];
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
 - (void)loadView {
 
 }
 */

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
        cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Open Issues (%@)", @""), self.milestone.openIssues];
    } else if (section == kUITableViewControllerSectionInfoClosedIssues) {
        cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Closed Issues (%@)", @""), self.milestone.closedIssues];
    }
    
    return cell;
}

#pragma mark - pagination

- (void)downloadDataForPage:(NSUInteger)page inSection:(NSUInteger)section {
    if (section == kUITableViewControllerSectionInfoOpenIssues) {
        [GHAPIIssueV3 issuesOnRepository:self.repository milestone:self.milestoneNumber 
                                  labels:nil 
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
        [GHAPIIssueV3 issuesOnRepository:self.repository milestone:self.milestoneNumber 
                                  labels:nil
                                   state:kGHAPIIssueStateV3Closed page:1 
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
        [GHAPIIssueV3 issuesOnRepository:self.repository milestone:self.milestoneNumber labels:nil state:kGHAPIIssueStateV3Open page:1 
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
        [GHAPIIssueV3 issuesOnRepository:self.repository milestone:self.milestoneNumber labels:nil state:kGHAPIIssueStateV3Closed page:1 
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
    // Return the number of sections.
    if (!self.milestone) {
        return 0;
    }
    return kUITableViewControllerNumberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (section == kUITableViewControllerSectionInfoOpenIssues) {
        return self.openIssues.count + 1;
    } else if (section == kUITableViewControllerSectionInfoClosedIssues) {
        return self.closedIssues.count + 1;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == kUITableViewControllerSectionInfoOpenIssues) {
        if (indexPath.row > 0 && indexPath.row <= [self.openIssues count]) {
            static NSString *CellIdentifier = @"GHPImageDetailTableViewCell";
            
            GHPImageDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[[GHPImageDetailTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
            }
            [self setupDefaultTableViewCell:cell forRowAtIndexPath:indexPath];
            
            GHAPIIssueV3 *issue = [self.openIssues objectAtIndex:indexPath.row - 1];
            
            [self updateImageView:cell.imageView atIndexPath:indexPath withGravatarID:issue.user.gravatarID];
            cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@ (%@ ago)", @""), issue.user.login, issue.createdAt.prettyTimeIntervalSinceNow];
            cell.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Issue %@ - %@", @""), issue.number, issue.title];
            
            // Configure the cell...
            
            return cell;
        }
    } else if (indexPath.section == kUITableViewControllerSectionInfoClosedIssues) {
        if (indexPath.row > 0 && indexPath.row <= [self.closedIssues count]) {
            static NSString *CellIdentifier = @"GHPImageDetailTableViewCell";
            
            GHPImageDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[[GHPImageDetailTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
            }
            [self setupDefaultTableViewCell:cell forRowAtIndexPath:indexPath];
            
            GHAPIIssueV3 *issue = [self.closedIssues objectAtIndex:indexPath.row - 1];
            
            [self updateImageView:cell.imageView atIndexPath:indexPath withGravatarID:issue.user.gravatarID];
            cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@ (%@ ago)", @""), issue.user.login, issue.createdAt.prettyTimeIntervalSinceNow];
            cell.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Issue %@ - %@", @""), issue.number, issue.title];
            
            // Configure the cell...
            
            return cell;
        }
    }
    
    return self.dummyCell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ((indexPath.section == kUITableViewControllerSectionInfoClosedIssues || indexPath.section == kUITableViewControllerSectionInfoOpenIssues) && indexPath.row > 0) {
        return [self cachedHeightForRowAtIndexPath:indexPath];
    }
    return UITableViewAutomaticDimension;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    GHAPIIssueV3 *issue = nil;
    UIViewController *viewController = nil;
    
    if (indexPath.section == kUITableViewControllerSectionInfoOpenIssues) {
        issue = [self.openIssues objectAtIndex:indexPath.row - 1];
    } else if (indexPath.section == kUITableViewControllerSectionInfoClosedIssues) {
        issue = [self.closedIssues objectAtIndex:indexPath.row - 1];
    }
    
    if (issue) {
        viewController = [[[GHPIssueViewController alloc] initWithIssueNumber:issue.number onRepository:self.repository] autorelease];
        [self.advancedNavigationController pushViewController:viewController afterViewController:self];
    }
}

#pragma mark - caching

- (void)cacheHeightForOpenIssuesArray {
    [self.openIssues enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        GHAPIIssueV3 *issue = obj;
        [self cacheHeight:[GHPImageDetailTableViewCell heightWithContent:[NSString stringWithFormat:NSLocalizedString(@"Issue %@ - %@", @""), issue.number, issue.title]] forRowAtIndexPath:[NSIndexPath indexPathForRow:idx+1 inSection:kUITableViewControllerSectionInfoOpenIssues]];
    }];
}

- (void)cacheHeightForClosedIssuesArray {
    [self.closedIssues enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        GHAPIIssueV3 *issue = obj;
        [self cacheHeight:[GHPImageDetailTableViewCell heightWithContent:[NSString stringWithFormat:NSLocalizedString(@"Issue %@ - %@", @""), issue.number, issue.title]] forRowAtIndexPath:[NSIndexPath indexPathForRow:idx+1 inSection:kUITableViewControllerSectionInfoClosedIssues]];
    }];
}

@end
