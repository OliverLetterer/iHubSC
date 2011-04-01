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
        
        [UIImage imageFromGravatarID:item.actorAttributes.gravatarID 
               withCompletionHandler:^(UIImage *image, NSError *error) {
                   cell.gravatarImageView.image = image;
        }];
        
        cell.actorLabel.text = [NSString stringWithFormat:@"%@ %@", item.actor, [NSString stringWithFormat:NSLocalizedString(@"%@ Issue %@", @""), payload.action, payload.number]];
        
        cell.repositoryLabel.text = payload.repo;
        
        [GHIssue issueOnRepository:payload.repo 
                        withNumber:payload.number 
                     loginUsername:[GHSettingsHelper username] 
                          password:[GHSettingsHelper password] 
                 completionHandler:^(GHIssue *issue, NSError *error, BOOL didDownload) {
                     
                     CGSize newLabelSize = [issue.title sizeWithFont:[UIFont boldSystemFontOfSize:14.0] 
                                                   constrainedToSize:CGSizeMake(222.0f, MAXFLOAT)
                                                       lineBreakMode:UILineBreakModeWordWrap];
                     
                     cell.statusLabel.text = issue.title;
                     CGRect statusLabelFrame = cell.statusLabel.frame;
                     statusLabelFrame.size = newLabelSize;
                     cell.statusLabel.frame = statusLabelFrame;
                     
                     if (didDownload) {
                         [self.tableView reloadData];
                     }
                     
                 }];
        
        return cell;
    }
    
    NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
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
        GHIssuePayload *payload = (GHIssuePayload *)item.payload;
        
        if ([GHIssue isIssueAvailableForRepository:payload.repo withNumber:payload.number]) {
            GHIssue *issue = [GHIssue issueFromDatabaseOnRepository:payload.repo withNumber:payload.number];
            
            CGSize newLabelSize = [issue.title sizeWithFont:[UIFont boldSystemFontOfSize:14.0] 
                                          constrainedToSize:CGSizeMake(222.0f, MAXFLOAT)
                                              lineBreakMode:UILineBreakModeWordWrap];
            
            if (newLabelSize.height < 21) {
                newLabelSize.height = 21;
            }
            
            height = newLabelSize.height + 20.0 + 30.0; // X + top offset of status label + 30 px white space on the bottom
        } else {
            height = [GHIssueFeedItemTableViewCell height];
        }
    }
    
    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
}

@end
