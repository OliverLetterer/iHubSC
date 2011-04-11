//
//  GHUserViewController.m
//  iGithub
//
//  Created by Oliver Letterer on 06.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHUserViewController.h"
#import "GithubAPI.h"
#import "GHFeedItemWithDescriptionTableViewCell.h"
#import "UICollapsingAndSpinningTableViewCell.h"
#import "GHSingleRepositoryViewController.h"

@implementation GHUserViewController

@synthesize repositoriesArray=_repositoriesArray;
@synthesize username=_username;
@synthesize watchedRepositoriesArray=_watchedRepositoriesArray;
@synthesize lastIndexPathForSingleRepositoryViewController=_lastIndexPathForSingleRepositoryViewController;

#pragma mark - setters and getters

- (void)setTableView:(UIExpandableTableView *)tableView {
    [super setTableView:tableView];
}

- (UIExpandableTableView *)tableView {
    return (UIExpandableTableView *)[super tableView];
}

- (void)setUsername:(NSString *)username {
    [_username release];
    _username = [username copy];
    self.title = self.username;
    [self downloadRepositories];
}

#pragma mark - Initialization

- (id)initWithUsername:(NSString *)username {
    if ((self = [super initWithStyle:UITableViewStylePlain])) {
        // Custom initialization
        self.pullToReleaseEnabled = YES;
        self.username = username;
    }
    return self;
}

#pragma mark - Memory management

- (void)dealloc {
    [_repositoriesArray release];
    [_username release];
    [_watchedRepositoriesArray release];
    [_lastIndexPathForSingleRepositoryViewController release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - target actions

- (void)createRepositoryButtonClicked:(UIBarButtonItem *)button {
    GHCreateRepositoryViewController *createViewController = [[[GHCreateRepositoryViewController alloc] init] autorelease];
    createViewController.delegate = self;
    
    UINavigationController *navController = [[[UINavigationController alloc] initWithRootViewController:createViewController] autorelease];
    [self presentModalViewController:navController animated:YES];
}

#pragma mark - instance methods

- (void)downloadRepositories {
    [GHRepository repositoriesForUserNamed:self.username 
                         completionHandler:^(NSArray *array, NSError *error) {
                             if (error) {
                                 [self handleError:error];
                             } else {
                                 self.repositoriesArray = array;
                             }
                             [self cacheHeightForTableView];
                             [self didReloadData];
                             [self.tableView reloadData];
                         }];
}

- (void)reloadData {
    [self downloadRepositories];
    if (self.watchedRepositoriesArray != nil) {
        [self downloadWatchedRepositories];
    }
}

- (void)cacheHeightForTableView {
    NSInteger i = 0;
    for (GHRepository *repo in self.repositoriesArray) {
        CGFloat height = [self heightForDescription:repo.desctiptionRepo] + 50.0;
        
        if (height < 71.0) {
            height = 71.0;
        }
        
        [self cacheHeight:height forRowAtIndexPath:[NSIndexPath indexPathForRow:i+1 inSection:0]];
        
        i++;
    }
}

- (void)cacheHeightForWatchedRepositories {
    NSInteger i = 0;
    for (GHRepository *repo in self.watchedRepositoriesArray) {
        CGFloat height = [self heightForDescription:repo.desctiptionRepo] + 50.0;
        
        if (height < 71.0) {
            height = 71.0;
        }
        
        [self cacheHeight:height forRowAtIndexPath:[NSIndexPath indexPathForRow:i+1 inSection:1]];
        
        i++;
    }
}

- (void)downloadWatchedRepositories {
    [GHRepository watchedRepositoriesOfUser:self.username 
                          completionHandler:^(NSArray *array, NSError *error) {
                              if (error) {
                                  [self handleError:error];
                              } else {
                                  self.watchedRepositoriesArray = array;
                                  [self cacheHeightForWatchedRepositories];
                                  [self.tableView reloadData];
                              }
                          }];
}

#pragma mark - View lifecycle

- (void)loadView {
    self.tableView = [[[UIExpandableTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain] autorelease];
    self.view = self.tableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if ([[GHAuthenticationManager sharedInstance].username isEqualToString:self.username]) {
        self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd 
                                                                                                target:self 
                                                                                                action:@selector(createRepositoryButtonClicked:)]
                                                  autorelease];
    }
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
    return YES;
}

- (BOOL)tableView:(UIExpandableTableView *)tableView needsToDownloadDataForExpandableSection:(NSInteger)section {
    if (section == 0) {
        return self.repositoriesArray == nil;
    } else if (section == 1) {
        return self.watchedRepositoriesArray == nil;
    }
    return NO;
}

- (UITableViewCell<UIExpandingTableViewCell> *)tableView:(UIExpandableTableView *)tableView expandingCellForSection:(NSInteger)section {
    NSString *CellIdientifier = @"UICollapsingAndSpinningTableViewCell";
    
    UICollapsingAndSpinningTableViewCell *cell = (UICollapsingAndSpinningTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdientifier];
    
    if (cell == nil) {
        cell = [[[UICollapsingAndSpinningTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdientifier] autorelease];
    }
    
    if (section == 0) {
        cell.textLabel.text = NSLocalizedString(@"Repositories", @"");
    } else if (section == 1) {
        cell.textLabel.text = NSLocalizedString(@"Watched Repositories", @"");
    }
    
    return cell;
}

#pragma mark - UIExpandableTableViewDelegate

- (void)tableView:(UIExpandableTableView *)tableView downloadDataForExpandableSection:(NSInteger)section {
    if (section == 0) {
        [GHRepository repositoriesForUserNamed:self.username 
                             completionHandler:^(NSArray *array, NSError *error) {
                                 if (error) {
                                     [self handleError:error];
                                 } else {
                                     self.repositoriesArray = array;
                                     [self cacheHeightForTableView];
                                     [self.tableView expandSection:section animated:YES];
                                 }
                                 [self didReloadData];
                             }];
    } else if (section == 1) {
        [GHRepository watchedRepositoriesOfUser:self.username 
                              completionHandler:^(NSArray *array, NSError *error) {
                                  if (error) {
                                      [self handleError:error];
                                  } else {
                                      self.watchedRepositoriesArray = array;
                                      [self cacheHeightForWatchedRepositories];
                                      [self.tableView expandSection:section animated:YES];
                                  }
                              }];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    // 0: all repositories
    // 1: watching
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    CGFloat result = 0;
    
    if (section == 0) {
        result = [self.repositoriesArray count];
    } else if (section == 1) {
        // watched
        result = [self.watchedRepositoriesArray count];
    }
    return result;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        // display all repostories
        NSString *CellIdentifier = @"GHFeedItemWithDescriptionTableViewCell";
        
        GHFeedItemWithDescriptionTableViewCell *cell = (GHFeedItemWithDescriptionTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[GHFeedItemWithDescriptionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        }
        
        GHRepository *repository = [self.repositoriesArray objectAtIndex:indexPath.row];
        
        cell.titleLabel.text = repository.name;
        cell.descriptionLabel.text = repository.desctiptionRepo;
        
        if ([repository.private boolValue]) {
            cell.imageView.image = [UIImage imageNamed:@"GHPrivateRepositoryIcon.png"];
        } else {
            cell.imageView.image = [UIImage imageNamed:@"GHPublicRepositoryIcon.png"];
        }
        
        // Configure the cell...
        
        return cell;
    } else if (indexPath.section == 1) {
        // watched repositories
        if (indexPath.row <= [self.watchedRepositoriesArray count] ) {
            NSString *CellIdentifier = @"GHFeedItemWithDescriptionTableViewCell";
            
            GHFeedItemWithDescriptionTableViewCell *cell = (GHFeedItemWithDescriptionTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[[GHFeedItemWithDescriptionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            }
            
            GHRepository *repository = [self.watchedRepositoriesArray objectAtIndex:indexPath.row];
            
            cell.titleLabel.text = [NSString stringWithFormat:@"%@/%@", repository.owner, repository.name];
            
            cell.descriptionLabel.text = repository.desctiptionRepo;
            
            if ([repository.private boolValue]) {
                cell.imageView.image = [UIImage imageNamed:@"GHPrivateRepositoryIcon.png"];
            } else {
                cell.imageView.image = [UIImage imageNamed:@"GHPublicRepositoryIcon.png"];
            }
            
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        GHRepository *repo = [self.repositoriesArray objectAtIndex:indexPath.row];
        
        GHSingleRepositoryViewController *viewController = [[[GHSingleRepositoryViewController alloc] initWithRepositoryString:[NSString stringWithFormat:@"%@/%@", repo.owner, repo.name] ] autorelease];
        viewController.delegate = self;
        self.lastIndexPathForSingleRepositoryViewController = indexPath;
        [self.navigationController pushViewController:viewController animated:YES];
        
    } else if (indexPath.section == 1 && indexPath.row > 0) {
        GHRepository *repo = [self.watchedRepositoriesArray objectAtIndex:indexPath.row];
        
        GHSingleRepositoryViewController *viewController = [[[GHSingleRepositoryViewController alloc] initWithRepositoryString:[NSString stringWithFormat:@"%@/%@", repo.owner, repo.name] ] autorelease];
        viewController.delegate = self;
        self.lastIndexPathForSingleRepositoryViewController = indexPath;
        [self.navigationController pushViewController:viewController animated:YES];
    } else {
        [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row > 0) {
        return [self cachedHeightForRowAtIndexPath:indexPath];
    } else if (indexPath.section == 1 && indexPath.row > 0) {
        // watched repo
        return [self cachedHeightForRowAtIndexPath:indexPath];
    }
    return 44.0;
}

#pragma mark - GHCreateRepositoryViewControllerDelegate

- (void)createRepositoryViewController:(GHCreateRepositoryViewController *)createRepositoryViewController 
                   didCreateRepository:(GHRepository *)repository {
    [self dismissModalViewControllerAnimated:YES];
    [self downloadRepositories];
}

- (void)createRepositoryViewControllerDidCancel:(GHCreateRepositoryViewController *)createRepositoryViewController {
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - GHSingleRepositoryViewControllerDelegate

- (void)singleRepositoryViewControllerDidDeleteRepository:(GHSingleRepositoryViewController *)singleRepositoryViewController {
    
    NSArray *oldArray = self.lastIndexPathForSingleRepositoryViewController.section == 0 ? self.repositoriesArray : self.watchedRepositoriesArray;
    NSUInteger index = self.lastIndexPathForSingleRepositoryViewController.row;
    if (self.lastIndexPathForSingleRepositoryViewController.section == 1) {
        index--;
    }
    NSMutableArray *array = [[oldArray mutableCopy] autorelease];
    [array removeObjectAtIndex:index];

    if (self.lastIndexPathForSingleRepositoryViewController.section == 0) {
        self.repositoriesArray = array;
    } else {
        self.watchedRepositoriesArray = array;
    }
    
    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:self.lastIndexPathForSingleRepositoryViewController] 
                          withRowAnimation:UITableViewRowAnimationTop];
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
