//
//  GHPMileStonesTableViewController.m
//  iGithub
//
//  Created by Oliver Letterer on 05.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHPMileStonesTableViewController.h"
#import "GHPMileStoneTableViewCell.h"
#import "GHPMilestoneViewController.h"

@implementation GHPMileStonesTableViewController

@synthesize milestones=_milestones;
@synthesize repository=_repository;

#pragma mark - setters and getters

- (void)setMilestones:(NSMutableArray *)milestones {
    if (milestones != _milestones) {
        [_milestones release], _milestones = [milestones retain];
        
        if (milestones != nil && milestones.count == 0) {
            UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"") 
                                                             message:NSLocalizedString(@"No Milestones available", @"") 
                                                            delegate:nil 
                                                   cancelButtonTitle:NSLocalizedString(@"OK", @"") 
                                                   otherButtonTitles:nil]
                                  autorelease];
            [alert show];
            [self.advancedNavigationController popViewController:self];
        }
        
        if (self.isViewLoaded) {
            [self.tableView reloadData];
        }
    }
}

#pragma mark - Initialization

- (id)initWithRepository:(NSString *)repository {
    if ((self = [super initWithStyle:UITableViewStyleGrouped])) {
        // Custom initialization
        self.repository = repository;
    }
    return self;
}

#pragma mark - Memory management

- (void)dealloc {
    [_milestones release];
    [_repository release];
    
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (!self.milestones) {
        return 0;
    }
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.milestones.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"GHPMileStoneTableViewCell";
    
    GHPMileStoneTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[GHPMileStoneTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    [self setupDefaultTableViewCell:cell forRowAtIndexPath:indexPath];
    
    GHAPIMilestoneV3 *milestone = [self.milestones objectAtIndex:indexPath.row];
    
    cell.progressView.progress = milestone.progress;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Milestone %@", @""), milestone.title];
    cell.detailTextLabel.text = milestone.dueFormattedString;
    
    if (milestone.dueInTime) {
        [cell.progressView setTintColor:[UIColor greenColor] ];
    } else {
        [cell.progressView setTintColor:[UIColor redColor] ];
    }
    
    return cell;
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
    return GHPMileStoneTableViewCellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    GHAPIMilestoneV3 *milestone = [self.milestones objectAtIndex:indexPath.row];
    
    GHPMilestoneViewController *viewController = [[[GHPMilestoneViewController alloc] initWithRepository:self.repository milestoneNumber:milestone.number] autorelease];
    
    [self.advancedNavigationController pushViewController:viewController afterViewController:self];
}

@end
