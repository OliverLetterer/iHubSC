//
//  GHSearchViewController.m
//  iGithub
//
//  Created by Oliver Letterer on 20.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHSearchViewController.h"
#import "GHSearchRepositoryViewController.h"
#import "GHSearchUserViewController.h"

@implementation GHSearchViewController

@synthesize searchBar=_searchBar, searchString=_searchString, backgroundGradientLayer=_backgroundGradientLayer;

#pragma mark - Initialization

- (id)init {
    if ((self = [super init])) {
        // Custom initialization
        self.tabBarItem = [[[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemSearch tag:0] autorelease];
        self.title = NSLocalizedString(@"Search", @"");
    }
    return self;
}

#pragma mark - Memory management

- (void)dealloc {
    [_searchBar release];
    [_mySearchDisplayController release];
    [_backgroundGradientLayer release];
    [_searchString release];
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)loadView {
    [super loadView];
    
    self.backgroundGradientLayer = [CAGradientLayer layer];
    self.backgroundGradientLayer.colors = [NSArray arrayWithObjects:
                                           (id)[UIColor whiteColor].CGColor, 
                                           (id)[UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0].CGColor,
                                           nil];
    self.backgroundGradientLayer.locations = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.0], [NSNumber numberWithFloat:1.0], nil];
    self.backgroundGradientLayer.frame = self.view.bounds;
    [self.view.layer addSublayer:self.backgroundGradientLayer];
    
    self.searchBar = [[[UISearchBar alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 44.0)] autorelease];
    self.searchBar.delegate = self;
    [self.view addSubview:self.searchBar];
    
    _mySearchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
    _mySearchDisplayController.searchResultsDataSource = self;
    _mySearchDisplayController.searchResultsDelegate = self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    [_searchBar release];
    _searchBar = nil;
    [_backgroundGradientLayer release];
    _backgroundGradientLayer = nil;
    
    [_mySearchDisplayController release];
    _mySearchDisplayController = nil;
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
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    if (indexPath.row == 0) {
        cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Repositores like \"%@\"", @""), self.searchString];
    } else if (indexPath.row == 1) {
        cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"User like \"%@\"", @""), self.searchString];
    }

    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
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
    if (indexPath.row == 0) {
        // repository
        GHSearchRepositoryViewController *searchViewController = [[[GHSearchRepositoryViewController alloc] initWithSearchString:self.searchString] autorelease];
        [self.navigationController pushViewController:searchViewController animated:YES];
    } else if (indexPath.row == 1) {
        // seach user
        GHSearchUserViewController *searchViewController = [[[GHSearchUserViewController alloc] initWithSearchString:self.searchString] autorelease];
        [self.navigationController pushViewController:searchViewController animated:YES];
    }
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    return YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    self.searchString = searchText;
    [_mySearchDisplayController.searchResultsTableView reloadData];
}

@end