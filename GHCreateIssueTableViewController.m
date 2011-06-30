//
//  GHCreateIssueTableViewController.m
//  iGithub
//
//  Created by Oliver Letterer on 14.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHCreateIssueTableViewController.h"
#import "GHCreateIssueTableViewCell.h"
#import "GHSettingsHelper.h"
#import "UICollapsingAndSpinningTableViewCell.h"

#define kUITableViewSectionTitle 0
#define kUITableViewSectionAssigned 1
#define kUITableViewSectionMilestones 2

@implementation GHCreateIssueTableViewController

@synthesize delegate=_delegate;
@synthesize repository=_repository;
@synthesize textViewToolBar=_textViewToolBar, textView=_textView, collaborators=_collaborators, milestones=_milestones;

#pragma mark - Initialization

- (id)initWithRepository:(NSString *)repository {
    if ((self = [super initWithStyle:UITableViewStylePlain])) {
        // Custom initialization
        self.title = NSLocalizedString(@"New Issue", @"");
        self.repository = repository;
    }
    return self;
}

#pragma mark - Memory management

- (void)dealloc {
    [_repository release];
    [_textViewToolBar release];
    [_textView release];
    [_collaborators release];
    [_milestones release];
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - target actions

- (void)toolbarDoneButtonClicked:(UIBarButtonItem *)barButton {
    [self.textView resignFirstResponder];
}

- (void)saveButtonClicked:(UIBarButtonItem *)sender {
    GHCreateIssueTableViewCell *cell = (GHCreateIssueTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:kUITableViewSectionTitle] ];
    
    GHAPIUserV3 *assignee = nil;
    NSNumber *milestoneNumber = nil;
    
    if (_assignIndex > 0) {
        assignee = [self.collaborators objectAtIndex:_assignIndex - 1];
    }
    if (_assignesMilestoneIndex > 0) {
        GHAPIMilestoneV3 *milestone = [self.milestones objectAtIndex:_assignesMilestoneIndex - 1];
        milestoneNumber = milestone.number;
    }
    
    [GHAPIIssueV3 createIssueOnRepository:self.repository title:cell.titleTextField.text 
                                  body:cell.descriptionTextField.text assignee:assignee.login milestone:milestoneNumber 
                     completionHandler:^(GHAPIIssueV3 *issue, NSError *error) {
                         if (error) {
                             [self handleError:error];
                         } else {
                             [self.delegate createIssueViewController:self didCreateIssue:issue];
                         }
                     }];
}

- (void)cancelButtonClicked:(UIBarButtonItem *)sender {
    [self.delegate createIssueViewControllerDidCancel:self];
}

#pragma mark - View lifecycle

/*
 - (void)loadView {
 
 }
 */

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *cancelButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel 
                                                                                   target:self 
                                                                                   action:@selector(cancelButtonClicked:)]
                                     autorelease];
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    UIBarButtonItem *saveButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave 
                                                                                 target:self 
                                                                                 action:@selector(saveButtonClicked:)]
                                   autorelease];
    self.navigationItem.rightBarButtonItem = saveButton;
    
    
    self.textViewToolBar = [[[UIToolbar alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 44.0)] autorelease];
    self.textViewToolBar.barStyle = UIBarStyleBlackTranslucent;
    
    UIBarButtonItem *item = nil;
    NSMutableArray *items = [NSMutableArray array];
    
    item = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace 
                                                          target:nil 
                                                          action:@selector(noAction)]
            autorelease];
    [items addObject:item];
    
    item = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", @"") 
                                             style:UIBarButtonItemStyleDone 
                                            target:self 
                                            action:@selector(toolbarDoneButtonClicked:)]
            autorelease];
    [items addObject:item];
    
    self.textViewToolBar.items = items;
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    self.textViewToolBar = nil;
    self.textView = nil;
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
    
    NSString *CellIdentifier = @"UICollapsingAndSpinningTableViewCell";
    
    UICollapsingAndSpinningTableViewCell *cell = (UICollapsingAndSpinningTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UICollapsingAndSpinningTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    if (section == kUITableViewSectionAssigned) {
        if (_assignIndex != 0) {
            cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Assigned to %@", @""), [self.collaborators objectAtIndex:_assignIndex-1]];
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
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (section == kUITableViewSectionTitle) {
        return 1;
    } else if (section == kUITableViewSectionAssigned) {
        return self.collaborators.count + 1;
    } else if (section == kUITableViewSectionMilestones) {
        return self.milestones.count + 1;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == kUITableViewSectionTitle) {
        if (indexPath.row == 0) {
            NSString *CellIdentifier = @"GHCreateIssueTableViewCell";
            
            GHCreateIssueTableViewCell *cell = (GHCreateIssueTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[[GHCreateIssueTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            
            [self updateImageViewForCell:cell atIndexPath:indexPath withGravatarID:[GHSettingsHelper gravatarID] ];
            
            cell.descriptionTextField.inputAccessoryView = self.textViewToolBar;
            self.textView = cell.descriptionTextField;
            
            return cell;
        }
    } else if (indexPath.section == kUITableViewSectionAssigned) {
        NSString *CellIdentifier = @"DetailsTableViewCell";
        
        UITableViewCellWithLinearGradientBackgroundView *cell = (UITableViewCellWithLinearGradientBackgroundView *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (!cell) {
            cell = [[[UITableViewCellWithLinearGradientBackgroundView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        }
        
        GHAPIUserV3 *user = [self.collaborators objectAtIndex:indexPath.row - 1];
        
        if (indexPath.row == _assignIndex) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        
        cell.textLabel.text = user.login;
        
        return cell;
    } else if (indexPath.section == kUITableViewSectionMilestones) {
        NSString *CellIdentifier = @"DetailsTableViewCell";
        
        UITableViewCellWithLinearGradientBackgroundView *cell = (UITableViewCellWithLinearGradientBackgroundView *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (!cell) {
            cell = [[[UITableViewCellWithLinearGradientBackgroundView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        }
        
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
    if (indexPath.section == kUITableViewSectionTitle) {
        return 200.0f;
    }
    
    return 44.0f;
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
