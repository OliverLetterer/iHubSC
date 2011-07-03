//
//  GHPCommitViewController.m
//  iGithub
//
//  Created by Oliver Letterer on 02.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHPCommitViewController.h"
#import "GHPCollapsingAndSpinningTableViewCell.h"
#import "GHPDiffViewTableViewCell.h"
#import "GHViewCloudFileViewController.h"

@implementation GHPCommitViewController

@synthesize repository=_repository, commitID=_commitID, commit=_commit;

#pragma mark - setters and getters

- (void)setCommit:(GHCommit *)commit {
    if (commit != _commit) {
        [_commit release];
        _commit = [commit retain];
        
        if (self.isViewLoaded) {
            [self.tableView reloadData];
        }
    }
}

- (void)setRepository:(NSString *)repository commitID:(NSString *)commitID {
    [_repository release];
    [_commitID release];
    
    _repository = [repository copy];
    _commitID = [commitID copy];
    self.commit = nil;
    self.isDownloadingEssentialData = YES;
    [GHCommit commit:_commitID onRepository:_repository completionHandler:^(GHCommit *commit, NSError *error) {
        self.isDownloadingEssentialData = NO;
        if (error) {
            [self handleError:error];
        } else {
            self.commit = commit;
        }
    }];
}

#pragma mark - Initialization

- (id)initWithRepository:(NSString *)repository commitID:(NSString *)commitID {
    if ((self = [super initWithStyle:UITableViewStyleGrouped])) {
        // Custom initialization
        [self setRepository:repository commitID:commitID];
    }
    return self;
}

#pragma mark - Memory management

- (void)dealloc {
    [_repository release];
    [_commitID release];
    [_commit release];
    
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
    return (section >= 0 && section <= self.commit.modified.count-1);
}

- (BOOL)tableView:(UIExpandableTableView *)tableView needsToDownloadDataForExpandableSection:(NSInteger)section {
    return NO;
}

- (UITableViewCell<UIExpandingTableViewCell> *)tableView:(UIExpandableTableView *)tableView expandingCellForSection:(NSInteger)section {
    GHPCollapsingAndSpinningTableViewCell *cell = [self defaultPadCollapsingAndSpinningTableViewCellForSection:section];
    
    GHCommitFileInformation *fileInfo = [self.commit.modified objectAtIndex:section];
    
    cell.textLabel.text = fileInfo.filename;
    
    return cell;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (!self.commit) {
        return 0;
    }
    // Return the number of sections.
    NSInteger count = 0;
    count += self.commit.modified.count;
    count += self.commit.added.count > 0;
    count += self.commit.removed.count > 0;
    
    return count;
}

// modified     0                               ->              self.commit.modified.count-1
// added        self.commit.modified.count
// removed      self.commit.modified.count + (self.commit.added.count > 0)

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section >= 0 && section <= self.commit.modified.count-1) {
        // modified:    filename + diff
        return 2;
    } else if (section == self.commit.modified.count && self.commit.added.count > 0) {
        // added
        return self.commit.added.count;
    } else if (section == (self.commit.modified.count + (self.commit.added.count > 0))) {
        // removed
        return self.commit.removed.count;
    }
    
    // Return the number of rows in the section.
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == self.commit.modified.count && self.commit.added.count > 0) {
        // added
        GHPDefaultTableViewCell *cell = [self defaultTableViewCellForRowAtIndexPath:indexPath withReuseIdentifier:@"GHPDefaultTableViewCell"];
        cell.textLabel.text = [self.commit.added objectAtIndex:indexPath.row];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        return cell;
    } else if (indexPath.section == (self.commit.modified.count + (self.commit.added.count > 0))) {
        // removed
        
        GHPDefaultTableViewCell *cell = [self defaultTableViewCellForRowAtIndexPath:indexPath withReuseIdentifier:@"GHPDefaultTableViewCell"];
        cell.textLabel.text = [self.commit.removed objectAtIndex:indexPath.row];
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        return cell;
    } else if (indexPath.section >= 0 && indexPath.section <= self.commit.modified.count-1) {
        // modified file
        static NSString *CellIdentifier = @"GHPDiffViewTableViewCell";
        
        GHPDiffViewTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[GHPDiffViewTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        }
        
        GHCommitFileInformation *fileInfo = [self.commit.modified objectAtIndex:indexPath.section];
        
        cell.diffView.diffString = fileInfo.diff;
        
        // Configure the cell...
        
        return cell;
    }
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    
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

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == self.commit.modified.count && self.commit.added.count > 0) {
        return UITableViewAutomaticDimension;
    } else if (section == (self.commit.modified.count + (self.commit.added.count > 0))) {
        return UITableViewAutomaticDimension;
    } else if (section == 0 && self.commit.modified.count > 0) {
        return UITableViewAutomaticDimension;
    }
    return 0.0f;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == self.commit.modified.count && self.commit.added.count > 0) {
        return NSLocalizedString(@"Added Files", @"");
    } else if (section == (self.commit.modified.count + (self.commit.added.count > 0))) {
        return NSLocalizedString(@"Removed Files", @"");
    } else if (section == 0 && self.commit.modified.count > 0) {
        return NSLocalizedString(@"Modified Files", @"");
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section >= 0 && indexPath.section <= self.commit.modified.count-1 && indexPath.row == 1) {
        GHCommitFileInformation *fileInfo = [self.commit.modified objectAtIndex:indexPath.section];
        
        return [GHPDiffViewTableViewCell heightWithContent:fileInfo.diff];
    }
    return UITableViewAutomaticDimension;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == self.commit.modified.count && self.commit.added.count > 0) {
        NSString *filename = [self.commit.added objectAtIndex:indexPath.row];
        
        NSString *URL = [filename stringByDeletingLastPathComponent];
        NSString *base = [filename lastPathComponent];
        
        GHViewCloudFileViewController *fileViewController = [[[GHViewCloudFileViewController alloc] initWithRepository:self.repository 
                                                                                                                  tree:self.commitID 
                                                                                                              filename:base 
                                                                                                           relativeURL:URL]
                                                             autorelease];
        [self.advancedNavigationController pushViewController:fileViewController afterViewController:self];
    }
}

@end
