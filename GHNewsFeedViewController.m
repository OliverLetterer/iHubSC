//
//  GHNewsFeedViewController.m
//  iGithub
//
//  Created by Oliver Letterer on 30.03.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHNewsFeedViewController.h"
#import "GithubAPI.h"
#import "GHSettingsHelper.h"
#import "GHIssueFeedItemTableViewCell.h"

@implementation GHNewsFeedViewController

@synthesize segmentControl=_segmentControl, newsFeed=_newsFeed;

#pragma mark - Initialization

- (id)init {
    if ((self = [super initWithStyle:UITableViewStylePlain])) {
        // Custom initialization
    }
    return self;
}

#pragma mark - Memory management

- (void)dealloc {
    [_segmentControl release];
    [_newsFeed release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    self.segmentControl = [[[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:
                                                                      NSLocalizedString(@"News Feed", @""), 
                                                                      NSLocalizedString(@"My Actions", @""), 
                                                                      nil]] 
                           autorelease];
    self.segmentControl.segmentedControlStyle = UISegmentedControlStyleBar;
    self.segmentControl.selectedSegmentIndex = 0;
    self.navigationItem.titleView = self.segmentControl;
    
    if ([GHSettingsHelper isUserAuthenticated]) {
        [GHNewsFeed privateNewsFeedForUserNamed:[GHSettingsHelper username] 
                                       password:[GHSettingsHelper password] 
                              completionHandler:^(GHNewsFeed *feed, NSError *error) {
                                  self.newsFeed = feed;
                                  [self.tableView reloadData];
                              }];
    }
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    [_segmentControl release];
    _segmentControl = nil;
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
    return [self.newsFeed.items count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    GHNewsFeedItem *item = [self.newsFeed.items objectAtIndex:indexPath.row];
    
    if (item.payload.type == GHPayloadTypeIssue) {
        NSString *CellIdentifier = @"GHIssueFeedItemTableViewCell";
        GHIssueFeedItemTableViewCell *cell = (GHIssueFeedItemTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (!cell) {
            cell = [[[GHIssueFeedItemTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        }
        
        GHIssuePayload *payload = (GHIssuePayload *)item.payload;
        
        [UIImage imageFromGravatarID:item.actorAttributes.gravatarID withCompletionHandler:^(UIImage *image, NSError *error) {
            cell.gravatarImageView.image = image;
        }];
        cell.actorLabel.text = item.actor;
        
        cell.statusLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@ Issue %@", @""), payload.action, payload.number];
        
        return cell;
    }
    
    NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    if (item.payload.type == GHPayloadTypeIssue) {
        cell.textLabel.text = @"Issue";
    } else {
        cell.textLabel.text = nil;
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
    GHNewsFeedItem *item = [self.newsFeed.items objectAtIndex:indexPath.row];
    
    CGFloat height = 10.0;
    
    if (item.payload.type == GHPayloadTypeIssue) {
        height = [GHIssueFeedItemTableViewCell height];
    }
    
    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
}

@end
