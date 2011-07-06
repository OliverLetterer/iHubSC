//
//  GHPCreateIssueViewController.m
//  iGithub
//
//  Created by Oliver Letterer on 02.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHPCreateIssueViewController.h"
#import "GHPCreateIssueTitleAndDescriptionTableViewCell.h"
#import "GHPCollapsingAndSpinningTableViewCell.h"

#define kUITableViewSectionTitleAndDescription      0
#define kUITableViewSectionAssigned                 1
#define kUITableViewSectionMilestones               2

#define kUITableViewNumberOfSections                3

@implementation GHPCreateIssueViewController

@synthesize delegate=_delegate, collaborators=_collaborators, milestones=_milestones, repository=_repository;

#pragma mark - Initialization

- (id)initWithRepository:(NSString *)repository delegate:(id<GHPCreateIssueViewControllerDelegate>)delegate {
    if ((self = [super initWithStyle:UITableViewStyleGrouped])) {
        // Custom initialization
        self.title = NSLocalizedString(@"Create a new Issue", @"");
        self.repository = repository;
        self.delegate = delegate;
    }
    return self;
}

#pragma mark - Memory management

- (void)dealloc {
    [_collaborators release];
    [_milestones release];
    [_repository release];
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - target actions

- (void)cancelButtonClicked:(UIBarButtonItem *)sender {
    [self.delegate createIssueViewControllerIsDone:self];
}

- (void)saveButtonClicked:(UIBarButtonItem *)sender {
    GHPCreateIssueTitleAndDescriptionTableViewCell *cell = (GHPCreateIssueTitleAndDescriptionTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:kUITableViewSectionTitleAndDescription] ];
    
    GHAPIUserV3 *assignee = nil;
    NSNumber *milestoneNumber = nil;
    
    if (_assignIndex > 0) {
        assignee = [self.collaborators objectAtIndex:_assignIndex - 1];
    }
    if (_assignesMilestoneIndex > 0) {
        GHAPIMilestoneV3 *milestone = [self.milestones objectAtIndex:_assignesMilestoneIndex - 1];
        milestoneNumber = milestone.number;
    }
    
    [GHAPIIssueV3 createIssueOnRepository:self.repository 
                                    title:cell.textField.text 
                                     body:cell.textView.text 
                                 assignee:assignee.login milestone:milestoneNumber 
                        completionHandler:^(GHAPIIssueV3 *issue, NSError *error) {
                            if (error) {
                                [self handleError:error];
                            } else {
                                [self.delegate createIssueViewController:self didCreateIssue:issue];
                            }
                        }];
}

#pragma mark - View lifecycle

/*
 - (void)loadView {
 
 }
 */

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonClicked:)] autorelease];
    
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveButtonClicked:)] autorelease];
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
    return section == kUITableViewSectionAssigned || section == kUITableViewSectionMilestones;
}

- (BOOL)tableView:(UIExpandableTableView *)tableView needsToDownloadDataForExpandableSection:(NSInteger)section {
    if (section == kUITableViewSectionAssigned) {
        return self.collaborators == nil;
    } else if (section == kUITableViewSectionMilestones) {
        return self.milestones == nil && !_hasCollaboratorState;
    }
    return NO;
}

- (UITableViewCell<UIExpandingTableViewCell> *)tableView:(UIExpandableTableView *)tableView expandingCellForSection:(NSInteger)section {
    
    GHPCollapsingAndSpinningTableViewCell *cell = [self defaultPadCollapsingAndSpinningTableViewCellForSection:section];
    
    if (section == kUITableViewSectionAssigned) {
        if (_assignIndex != 0) {
            GHAPIUserV3 *user = [self.collaborators objectAtIndex:_assignIndex-1];
            cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Assigned to %@", @""), user.login];
        } else {
            cell.textLabel.text = NSLocalizedString(@"Assign to", @"");
        }
    } else if (section == kUITableViewSectionMilestones) {
        if (_assignesMilestoneIndex != 0) {
            GHAPIMilestoneV3 *milestone = [self.milestones objectAtIndex:_assignesMilestoneIndex - 1];
            cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Milestone (%@)", @""), milestone.title];
        } else {
            cell.textLabel.text = NSLocalizedString(@"Select Milestone", @"");
        }
    }
    
    return cell;
}

#pragma mark - UIExpandableTableViewDelegate

- (void)tableView:(UIExpandableTableView *)tableView downloadDataForExpandableSection:(NSInteger)section {
    if (section == kUITableViewSectionAssigned) {
        [GHAPIRepositoryV3 collaboratorsForRepository:self.repository page:1 
                                    completionHandler:^(NSMutableArray *array, NSUInteger nextPage, NSError *error) {
                                        if (error) {
                                            [self handleError:error];
                                            [tableView cancelDownloadInSection:section];
                                        } else {
                                            self.collaborators = array;
                                            [self setNextPage:nextPage forSection:section];
                                            [tableView expandSection:section animated:YES];
                                        }
                                    }];
    } else if (section == kUITableViewSectionMilestones) {
        [GHAPIRepositoryV3 isUser:[GHAuthenticationManager sharedInstance].username 
         collaboratorOnRepository:self.repository 
                completionHandler:^(BOOL state, NSError *error) {
                    if (error) {
                        [self handleError:error];
                        [tableView cancelDownloadInSection:section];
                    } else {
                        _hasCollaboratorState = YES;
                        _isCollaborator = state;
                        
                        if (_isCollaborator || [self.repository hasPrefix:[GHAuthenticationManager sharedInstance].username ]) {
                            [GHAPIIssueV3 milestonesForIssueOnRepository:self.repository withNumber:nil page:1 
                                                       completionHandler:^(NSMutableArray *array, NSUInteger nextPage, NSError *error) {
                                                           if (error) {
                                                               [self handleError:error];
                                                               [tableView cancelDownloadInSection:section];
                                                           } else {
                                                               self.milestones = array;
                                                               [self setNextPage:nextPage forSection:section];
                                                               [tableView expandSection:section animated:YES];
                                                           }
                                                       }];
                        } else {
                            [tableView cancelDownloadInSection:section];
                            UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"") 
                                                                             message:NSLocalizedString(@"You are not a Collaborator on this Repository. You don't have permission to assign a Milestone!", @"") 
                                                                            delegate:nil 
                                                                   cancelButtonTitle:NSLocalizedString(@"OK", @"") 
                                                                   otherButtonTitles:nil]
                                                  autorelease];
                            [alert show];
                        }
                    }
                }];
    }
}

#pragma mark - pagination

- (void)downloadDataForPage:(NSUInteger)page inSection:(NSUInteger)section {
    if (section == kUITableViewSectionMilestones) {
        [GHAPIIssueV3 milestonesForIssueOnRepository:self.repository withNumber:nil page:page 
                                   completionHandler:^(NSMutableArray *array, NSUInteger nextPage, NSError *error) {
                                       if (error) {
                                           [self handleError:error];
                                       } else {
                                           [self.milestones addObjectsFromArray:array];
                                           [self setNextPage:nextPage forSection:section];
                                           [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:section] 
                                                         withRowAnimation:UITableViewRowAnimationAutomatic];
                                       }
                                   }];
    } else if (section == kUITableViewSectionAssigned) {
        [GHAPIRepositoryV3 collaboratorsForRepository:self.repository page:page 
                                    completionHandler:^(NSMutableArray *array, NSUInteger nextPage, NSError *error) {
                                        if (error) {
                                            [self handleError:error];
                                        } else {
                                            [self.collaborators addObjectsFromArray:array];
                                            [self setNextPage:nextPage forSection:section];
                                            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:section] 
                                                          withRowAnimation:UITableViewRowAnimationAutomatic];
                                        }
                                    }];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return kUITableViewNumberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == kUITableViewSectionTitleAndDescription) {
        return 1;
    } else if (section == kUITableViewSectionAssigned) {
        return self.collaborators.count + 1;
    } else if (section == kUITableViewSectionMilestones) {
        return self.milestones.count + 1;
    }
    // Return the number of rows in the section.
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == kUITableViewSectionTitleAndDescription) {
        if (indexPath.row == 0) {
            NSString *CellIdentifier = @"GHPCreateIssueTitleAndDescriptionTableViewCell";
            
            GHPCreateIssueTitleAndDescriptionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[[GHPCreateIssueTitleAndDescriptionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            }
            [self setupDefaultTableViewCell:cell forRowAtIndexPath:indexPath];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            // Configure the cell...
            
            return cell;
        }
    } else if (indexPath.section == kUITableViewSectionAssigned) {
        NSString *CellIdentifier = @"GHPDefaultTableViewCell";
        GHPDefaultTableViewCell *cell = [self defaultTableViewCellForRowAtIndexPath:indexPath withReuseIdentifier:CellIdentifier];
        
        GHAPIUserV3 *user = [self.collaborators objectAtIndex:indexPath.row - 1];
        
        if (indexPath.row == _assignIndex) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        
        cell.textLabel.text = user.login;
        
        return cell;
    } else if (indexPath.section == kUITableViewSectionMilestones) {
        NSString *CellIdentifier = @"GHPDefaultTableViewCell";
        GHPDefaultTableViewCell *cell = [self defaultTableViewCellForRowAtIndexPath:indexPath withReuseIdentifier:CellIdentifier];
        
        GHAPIMilestoneV3 *milestone = [self.milestones objectAtIndex:indexPath.row - 1];
        
        if (indexPath.row == _assignesMilestoneIndex) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        
        cell.textLabel.text = milestone.title;
        
        return cell;
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
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            return 200.0f;
        }
    }
    
    return UITableViewAutomaticDimension;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == kUITableViewSectionAssigned) {
        _assignIndex = indexPath.row;
        [tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationNone];
    } else if (indexPath.section == kUITableViewSectionMilestones) {
        _assignesMilestoneIndex = indexPath.row;
        [tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationNone];
    } else {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
}

@end
