//
//  GHRepositoriesViewController.m
//  iGithub
//
//  Created by Oliver Letterer on 06.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHRepositoriesViewController.h"
#import "GithubAPI.h"
#import "GHFeedItemWithDescriptionTableViewCell.h"
#import "UICollapsingAndSpinningTableViewCell.h"
#import "GHSingleRepositoryViewController.h"

@implementation GHRepositoriesViewController

@synthesize repositoriesArray=_repositoriesArray;
@synthesize username=_username;
@synthesize watchedRepositoriesArray=_watchedRepositoriesArray;

#pragma mark - setters and getters

- (void)setUsername:(NSString *)username {
    [_username release];
    _username = [username copy];
    [self downloadRepositories];
}

#pragma mark - Initialization

- (id)initWithUsername:(NSString *)username {
    if ((self = [super initWithStyle:UITableViewStylePlain])) {
        // Custom initialization
        self.title = NSLocalizedString(@"Repositories", @"");
        self.pullToReleaseEnabled = YES;
        self.username = username;
        
        self.tabBarItem = [[[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Repositories", @"") 
                                                         image:[UIImage imageNamed:@"60-dialpad.png"] 
                                                           tag:0]
                           autorelease];
    }
    return self;
}

#pragma mark - Memory management

- (void)dealloc {
    [_repositoriesArray release];
    [_username release];
    [_watchedRepositoriesArray release];
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
        
        [self cacheHeight:height forRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        
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
    _isDownloadingWatchedRepositories = YES;
    
    [self.tableView reloadRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1] withRowAnimation:UITableViewRowAnimationFade];
    
    [GHRepository watchedRepositoriesOfUser:self.username 
                          completionHandler:^(NSArray *array, NSError *error) {
                              _isDownloadingWatchedRepositories = NO;
                              if (error) {
                                  [self handleError:error];
                              } else {
                                  self.watchedRepositoriesArray = array;
                                  [self cacheHeightForWatchedRepositories];
                                  if (_shouldShowWatchedRepositoriesAfterDownload) {
                                      [self showWatchedRepositories];
                                  }
                                  _shouldShowWatchedRepositoriesAfterDownload = NO;
                              }
                          }];
}

- (void)showWatchedRepositories {
    _isShowingWatchedRepositories = YES;
    
    [self.tableView beginUpdates];
    
    NSMutableArray *array = [NSMutableArray array];
    for (int i = 0; i < [self.watchedRepositoriesArray count]; i++) {
        [array addObject:[NSIndexPath indexPathForRow:i+1 inSection:1]];
    }
    
    [self.tableView insertRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationTop];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:1]] 
                          withRowAnimation:UITableViewRowAnimationFade];
    
    [self.tableView endUpdates];
    
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1] 
                          atScrollPosition:UITableViewScrollPositionTop 
                                  animated:YES];
}

- (void)hideWatchedRepositories {
    _isShowingWatchedRepositories = NO;
    [self.tableView beginUpdates];
    
    NSMutableArray *array = [NSMutableArray array];
    for (int i = 0; i < [self.watchedRepositoriesArray count]; i++) {
        [array addObject:[NSIndexPath indexPathForRow:i+1 inSection:1]];
    }
    
    [self.tableView deleteRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationTop];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:1]] 
                          withRowAnimation:UITableViewRowAnimationFade];
    
    [self.tableView endUpdates];
}

#pragma mark - View lifecycle

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
        result = 1;
        if (_isShowingWatchedRepositories) {
            result += [self.watchedRepositoriesArray count];
        }
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
        if (indexPath.row == 0) {
            NSString *CellIdientifier = @"UICollapsingAndSpinningTableViewCell";
            
            UICollapsingAndSpinningTableViewCell *cell = (UICollapsingAndSpinningTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdientifier];
            
            if (cell == nil) {
                cell = [[[UICollapsingAndSpinningTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdientifier] autorelease];
            }
            
            cell.textLabel.text = NSLocalizedString(@"Watched Repositories", @"");
            
            if (_isDownloadingWatchedRepositories) {
                [cell setSpinning:YES];
            } else {
                [cell setSpinning:NO];
                if (!_isShowingWatchedRepositories) {
                    cell.accessoryView.transform = CGAffineTransformMakeRotation(M_PI);
                } else {
                    cell.accessoryView.transform = CGAffineTransformIdentity;
                }
            }
            
            return cell;
        } else if (indexPath.row <= [self.watchedRepositoriesArray count] ) {
            NSString *CellIdentifier = @"GHFeedItemWithDescriptionTableViewCell";
            
            GHFeedItemWithDescriptionTableViewCell *cell = (GHFeedItemWithDescriptionTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[[GHFeedItemWithDescriptionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            }
            
            GHRepository *repository = [self.watchedRepositoriesArray objectAtIndex:indexPath.row-1];
            
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
    if (indexPath.section == 1 && indexPath.row == 0) {
        // watched clicked
        if (self.watchedRepositoriesArray == nil && !_isDownloadingWatchedRepositories) {
            _shouldShowWatchedRepositoriesAfterDownload = YES;
            [self downloadWatchedRepositories];
        } else {
            if (_isShowingWatchedRepositories) {
                [self hideWatchedRepositories];
            } else {
                [self showWatchedRepositories];
            }
        }
    } else if (indexPath.section == 0) {
        GHRepository *repo = [self.repositoriesArray objectAtIndex:indexPath.row];
        
        GHSingleRepositoryViewController *viewController = [[[GHSingleRepositoryViewController alloc] initWithRepository:[NSString stringWithFormat:@"%@/%@", repo.owner, repo.name] ] autorelease];
        
        [self.navigationController pushViewController:viewController animated:YES];
        
    } else if (indexPath.section == 1 && indexPath.row > 0) {
        GHRepository *repo = [self.watchedRepositoriesArray objectAtIndex:indexPath.row-1];
        
        GHSingleRepositoryViewController *viewController = [[[GHSingleRepositoryViewController alloc] initWithRepository:[NSString stringWithFormat:@"%@/%@", repo.owner, repo.name] ] autorelease];
        
        [self.navigationController pushViewController:viewController animated:YES];
    } else {
        [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
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

@end
