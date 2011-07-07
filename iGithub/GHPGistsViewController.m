//
//  GHPGistsViewController.m
//  iGithub
//
//  Created by Oliver Letterer on 07.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHPGistsViewController.h"
#import "GHPRepositoryTableViewCell.h"
#import "GHPGistViewController.h"

@implementation GHPGistsViewController

@synthesize gists=_gists;

#pragma mark - setters and getters

- (void)setGists:(NSMutableArray *)gists {
    if (gists != _gists) {
        [_gists release], _gists = [gists retain];
        
        [self cacheGistsHeights];
        if (self.isViewLoaded) {
            [self.tableView reloadData];
        }
    }
}

#pragma mark - Initialization

- (id)initWithStyle:(UITableViewStyle)style {
    if ((self = [super initWithStyle:style])) {
        // Custom initialization
    }
    return self;
}

#pragma mark - Memory management

- (void)dealloc {
    [_gists release];
    
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
    if (!self.gists) {
        return 0;
    }
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.gists.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"GHPRepositoryTableViewCell";
    
    GHPRepositoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[GHPRepositoryTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    [self setupDefaultTableViewCell:cell forRowAtIndexPath:indexPath];
    
    GHAPIGistV3 *gist = [self.gists objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Gist: %@ (created %@ ago)", @""), gist.ID, gist.createdAt.prettyTimeIntervalSinceNow];
    
    cell.detailTextLabel.text = gist.description;
    
    if ([gist.public boolValue]) {
        cell.imageView.image = [UIImage imageNamed:@"GHClipBoard.png"];
    } else {
        cell.imageView.image = [UIImage imageNamed:@"GHClipBoardPrivate.png"];
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
    return [self cachedHeightForRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    GHAPIGistV3 *gist = [self.gists objectAtIndex:indexPath.row];
    GHPGistViewController *viewController = [[[GHPGistViewController alloc] initWithGistID:gist.ID] autorelease];
    
    [self.advancedNavigationController pushViewController:viewController afterViewController:self];
}

#pragma mark - Height caching

- (void)cacheGistsHeights {
    [self.gists enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        GHAPIGistV3 *gist = obj;
        
        [self cacheHeight:[GHPRepositoryTableViewCell heightWithContent:gist.description] 
        forRowAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0]];
    }];
}

@end
