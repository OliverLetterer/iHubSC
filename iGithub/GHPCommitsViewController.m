//
//  GHPCommitsViewController.m
//  iGithub
//
//  Created by Oliver Letterer on 02.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHPCommitsViewController.h"
#import "GHPCommitTableViewCell.h"
#import "GHPCommitViewController.h"

@implementation GHPCommitsViewController

@synthesize repository=_repository, branchHash=_branchHash;
@synthesize commits=_commits;

#pragma mark - setters and getters

- (void)setCommits:(NSMutableArray *)commits {
    if (commits != _commits) {
        [_commits release];
        _commits = [commits retain];
        [self cacheCommitsHeights];
        
        if (commits != nil && commits.count == 0) {
            UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"") 
                                                             message:NSLocalizedString(@"No Commits available", @"") 
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

- (void)setRepository:(NSString *)repository branchHash:(NSString *)branchHash {
    [_repository release];
    [_branchHash release];
    
    _repository = [repository copy];
    _branchHash = [branchHash copy];
    self.commits = nil;
    self.isDownloadingEssentialData = YES;
    [GHAPIRepositoryV3 commitsOnRepository:self.repository branchSHA:self.branchHash page:1 
                         completionHandler:^(NSMutableArray *array, NSUInteger nextPage, NSError *error) {
                             self.isDownloadingEssentialData = NO;
                             if (error) {
                                 [self handleError:error];
                             } else {
                                 self.commits = array;
                                 [self setNextPage:nextPage forSection:0];
                             }
                         }];
}

#pragma mark - Pagination

- (void)downloadDataForPage:(NSUInteger)page inSection:(NSUInteger)section {
    [GHAPIRepositoryV3 commitsOnRepository:self.repository branchSHA:self.branchHash page:page 
                         completionHandler:^(NSMutableArray *array, NSUInteger nextPage, NSError *error) {
                             if (error) {
                                 [self handleError:error];
                             } else {
                                 [self setNextPage:nextPage forSection:section];
                                 [self.commits addObjectsFromArray:array];
                                 [self cacheCommitsHeights];
                                 [self.tableView reloadData];
                             }
                         }];
}

#pragma mark - Initialization

- (id)initWithRepository:(NSString *)repository branchHash:(NSString *)branchHash {
    if ((self = [super initWithStyle:UITableViewStyleGrouped])) {
        // Custom initialization
        [self setRepository:repository branchHash:branchHash];
    }
    return self;
}

#pragma mark - Memory management

- (void)dealloc {
    [_repository release];
    [_branchHash release];
    
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
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.commits.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *CellIdentifier = @"GHPCommitTableViewCell";
    
    GHPCommitTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[GHPCommitTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    [self setupDefaultTableViewCell:cell forRowAtIndexPath:indexPath];
    
    GHAPICommitV3 *commit = [self.commits objectAtIndex:indexPath.row];
    
    [self updateImageView:cell.imageView atIndexPath:indexPath withGravatarID:commit.committer.gravatarID];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ - %@", commit.committer.login, commit.SHA];
    cell.detailTextLabel.text = commit.message;
    
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

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self cachedHeightForRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    GHAPICommitV3 *commit = [self.commits objectAtIndex:indexPath.row];
    
    GHPCommitViewController *commitViewController = [[[GHPCommitViewController alloc] initWithRepository:self.repository 
                                                                                                commitID:commit.SHA]
                                                     autorelease];
    [self.advancedNavigationController pushViewController:commitViewController afterViewController:self];
}

#pragma mark - height caching

- (void)cacheCommitsHeights {
    [self.commits enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        GHAPICommitV3 *commit = obj;
        
        [self cacheHeight:[GHPCommitTableViewCell heightWithContent:commit.message] forRowAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0] ];
    }];
}

@end
