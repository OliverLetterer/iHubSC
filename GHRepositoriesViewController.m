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

@implementation GHRepositoriesViewController

@synthesize repositoriesArray=_repositoriesArray;
@synthesize username=_username;

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
    }
    return self;
}

#pragma mark - Memory management

- (void)dealloc {
    [_repositoriesArray release];
    [_username release];
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
                             [self dataSourceDidFinishLoadingNewData];
                             [self.tableView reloadData];
                         }];
}

- (void)reloadTableViewDataSource {
    [self downloadRepositories];
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.repositoriesArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"GHFeedItemWithDescriptionTableViewCell";
    
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
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self cachedHeightForRowAtIndexPath:indexPath];
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
