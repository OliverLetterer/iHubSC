//
//  GHViewLabelViewController.m
//  iGithub
//
//  Created by Oliver Letterer on 22.05.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHViewLabelViewController.h"
#import "GHLabelTableViewCell.h"
#import "UICollapsingAndSpinningTableViewCell.h"
#import "GHIssueTitleTableViewCell.h"
#import "GHViewIssueTableViewController.h"

#define kUITableViewSectionInfo                         0
#define kUITableViewControllerSectionInfoOpenIssues     1
#define kUITableViewControllerSectionInfoClosedIssues   2

#define kUITableViewNumberOfSections                    3

@implementation GHViewLabelViewController

@synthesize repositoryString=_repositoryString;
@synthesize label=_label;
@synthesize openIssues=_openIssues, closedIssues=_closedIssues;

#pragma mark - Initialization

- (id)initWithRepository:(NSString *)repository label:(GHAPILabelV3 *)label {
    if ((self = [super initWithStyle:UITableViewStylePlain])) {
        // Custom initialization
        self.repositoryString = repository;
        self.label = label;
        
        self.title = label.name;
    }
    return self;
}

#pragma mark - Memory management

- (void)dealloc {
    [_repositoryString release];
    [_label release];
    [_openIssues release];
    [_closedIssues release];
    
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
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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
    
    NSString *CellIdentifier = @"UICollapsingAndSpinningTableViewCell";
    
    UICollapsingAndSpinningTableViewCell *cell = (UICollapsingAndSpinningTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UICollapsingAndSpinningTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
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
    if (section == kUITableViewSectionInfo) {
        return 1;
    } else if (section == kUITableViewControllerSectionInfoOpenIssues) {
        return self.openIssues.count + 1;
    } else if (section == kUITableViewControllerSectionInfoClosedIssues) {
        return self.closedIssues.count + 1;
    }

    // Return the number of rows in the section.
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == kUITableViewSectionInfo) {
        if (indexPath.row == 0) {
            NSString *CellIdentifier = @"GHLabelTableViewCell";
            
            GHLabelTableViewCell *cell = (GHLabelTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (!cell) {
                cell = [[[GHLabelTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            }
            
            GHAPILabelV3 *label = self.label;
            
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            cell.textLabel.text = label.name;
            cell.colorView.backgroundColor = label.colorString.colorFromAPIColorString;
            
            return cell;
        }
    } else if (indexPath.section == kUITableViewControllerSectionInfoOpenIssues) {
        if (indexPath.row > 0 && indexPath.row <= [self.openIssues count]) {
            NSString *CellIdentifier = @"GHIssueTitleTableViewCell";
            GHIssueTitleTableViewCell *cell = (GHIssueTitleTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (!cell) {
                cell = [[[GHIssueTitleTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
            }
            
            GHAPIIssueV3 *issue = [self.openIssues objectAtIndex:indexPath.row - 1];
            
            cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Issue %@", @""), issue.number];
            
            [self updateImageViewForCell:cell 
                             atIndexPath:indexPath 
                          withGravatarID:issue.user.gravatarID];
            
            cell.detailTextLabel.text = [NSString stringWithFormat:@"by %@ %@", issue.user.login, [NSString stringWithFormat:NSLocalizedString(@"%@ ago", @""), issue.createdAt.prettyTimeIntervalSinceNow]];
            ;
            
            cell.descriptionLabel.text = issue.title;
            
            return cell;
        }
    } else if (indexPath.section == kUITableViewControllerSectionInfoClosedIssues) {
        if (indexPath.row > 0 && indexPath.row <= [self.closedIssues count]) {
            NSString *CellIdentifier = @"GHIssueTitleTableViewCell";
            GHIssueTitleTableViewCell *cell = (GHIssueTitleTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (!cell) {
                cell = [[[GHIssueTitleTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
            }
            
            GHAPIIssueV3 *issue = [self.closedIssues objectAtIndex:indexPath.row - 1];
            
            cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Issue %@", @""), issue.number];
            
            [self updateImageViewForCell:cell 
                             atIndexPath:indexPath 
                          withGravatarID:issue.user.gravatarID];
            
            cell.detailTextLabel.text = [NSString stringWithFormat:@"by %@ %@", issue.user.login, [NSString stringWithFormat:NSLocalizedString(@"%@ ago", @""), issue.createdAt.prettyTimeIntervalSinceNow]];
            ;
            
            cell.descriptionLabel.text = issue.title;
            
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
    if (indexPath.section == kUITableViewControllerSectionInfoOpenIssues && indexPath.row > 0) {
        return [self cachedHeightForRowAtIndexPath:indexPath];
    } else if (indexPath.section == kUITableViewControllerSectionInfoClosedIssues && indexPath.row > 0) {
        return [self cachedHeightForRowAtIndexPath:indexPath];
    }
    return 44.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == kUITableViewControllerSectionInfoOpenIssues && indexPath.row > 0) {
        GHAPIIssueV3 *issue = [self.openIssues objectAtIndex:indexPath.row - 1];
        
        GHViewIssueTableViewController *issueViewController = [[[GHViewIssueTableViewController alloc] initWithRepository:self.repositoryString 
                                                                                                              issueNumber:issue.number]
                                                               autorelease];
        [self.navigationController pushViewController:issueViewController animated:YES];
        
    } else if (indexPath.section == kUITableViewControllerSectionInfoClosedIssues && indexPath.row > 0) {
        GHAPIIssueV3 *issue = [self.closedIssues objectAtIndex:indexPath.row - 1];
        
        GHViewIssueTableViewController *issueViewController = [[[GHViewIssueTableViewController alloc] initWithRepository:self.repositoryString 
                                                                                                              issueNumber:issue.number]
                                                               autorelease];
        [self.navigationController pushViewController:issueViewController animated:YES];
        
    } else {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
}

#pragma mark - caching

- (void)cacheHeightForOpenIssuesArray {
    NSInteger i = 1;
    for (GHAPIIssueV3 *issue in self.openIssues) {
        [self cacheHeight:[self heightForDescription:issue.title]+50.0f forRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:kUITableViewControllerSectionInfoOpenIssues] ];
        i++;
    }
}

- (void)cacheHeightForClosedIssuesArray {
    NSInteger i = 1;
    for (GHAPIIssueV3 *issue in self.closedIssues) {
        [self cacheHeight:[self heightForDescription:issue.title]+50.0f forRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:kUITableViewControllerSectionInfoClosedIssues] ];
        i++;
    }
}

@end
