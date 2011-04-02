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
#import "GHPushFeedItemTableViewCell.h"

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
    self.segmentControl.userInteractionEnabled = NO;
    self.segmentControl.alpha = 0.5;
    [self.segmentControl addTarget:self action:@selector(segmentControlValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    if ([GHSettingsHelper isUserAuthenticated]) {
        [GHNewsFeed privateNewsFeedForUserNamed:[GHSettingsHelper username] 
                                       password:[GHSettingsHelper password] 
                              completionHandler:^(GHNewsFeed *feed, NSError *error) {
                                  self.newsFeed = feed;
                                  [self.tableView reloadData];
                                  self.segmentControl.userInteractionEnabled = YES;
                                  self.segmentControl.alpha = 1.0;
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

#pragma mark - target actions

- (void)segmentControlValueChanged:(UISegmentedControl *)segmentControl {
    
    self.newsFeed = nil;
    [self.tableView reloadData];
    self.segmentControl.userInteractionEnabled = NO;
    self.segmentControl.alpha = 0.5;
    
    if (segmentControl.selectedSegmentIndex == 0) {
        // News Feed
        [GHNewsFeed privateNewsFeedForUserNamed:[GHSettingsHelper username] 
                                       password:[GHSettingsHelper password] 
                              completionHandler:^(GHNewsFeed *feed, NSError *error) {
                                  self.newsFeed = feed;
                                  [self.tableView reloadData];
                                  self.segmentControl.userInteractionEnabled = YES;
                                  self.segmentControl.alpha = 1.0;
                              }];
    } else if (segmentControl.selectedSegmentIndex == 1) {
        // My Actions
        [GHNewsFeed usersNewsFeedForUserNamed:[GHSettingsHelper username] 
                                     password:[GHSettingsHelper password] 
                            completionHandler:^(GHNewsFeed *feed, NSError *error) {
                                self.newsFeed = feed;
                                [self.tableView reloadData];
                                self.segmentControl.userInteractionEnabled = YES;
                                self.segmentControl.alpha = 1.0;
                            }];
    }
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
        // we will display an issue
        NSString *CellIdentifier = @"GHIssueFeedItemTableViewCell";
        GHIssueFeedItemTableViewCell *cell = (GHIssueFeedItemTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (!cell) {
            cell = [[[GHIssueFeedItemTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        }
        
        GHIssuePayload *payload = (GHIssuePayload *)item.payload;
        
        UIImage *gravatarImage = [UIImage cachedImageFromGravatarID:item.actorAttributes.gravatarID];
        
        if (gravatarImage) {
            cell.imageView.image = gravatarImage;
            [cell.activityIndicatorView stopAnimating];
        } else {
            [cell.activityIndicatorView startAnimating];
            
            [UIImage imageFromGravatarID:item.actorAttributes.gravatarID 
                   withCompletionHandler:^(UIImage *image, NSError *error, BOOL didDownload) {
                       [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] 
                                             withRowAnimation:UITableViewRowAnimationNone];
                   }];

        }
        
                
        cell.titleLabel.text = [NSString stringWithFormat:@"%@ %@", item.actor, [NSString stringWithFormat:NSLocalizedString(@"%@ Issue %@", @""), payload.action, payload.number]];
        
        cell.repositoryLabel.text = payload.repo;
        
        GHIssue *issue = [GHIssue issueFromDatabaseOnRepository:payload.repo withNumber:payload.number];
        
        if (issue) {            
            cell.descriptionLabel.text = issue.title;
        } else {
            [GHIssue issueOnRepository:payload.repo 
                            withNumber:payload.number 
                         loginUsername:[GHSettingsHelper username] 
                              password:[GHSettingsHelper password] 
                     completionHandler:^(GHIssue *issue, NSError *error, BOOL didDownload) {
                         
                         [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] 
                                               withRowAnimation:UITableViewRowAnimationNone];
                     }];

        }
                
        return cell;
    } else if (item.payload.type == GHPayloadTypePush) {
        // tableView is asking for a push item
        
        NSString *CellIdentifier = @"GHPushFeedItemTableViewCell";
        GHPushFeedItemTableViewCell *cell = (GHPushFeedItemTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (!cell) {
            cell = [[[GHPushFeedItemTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        }
        
        GHPushPayload *payload = (GHPushPayload *)item.payload;
        
        UIImage *gravatarImage = [UIImage cachedImageFromGravatarID:item.actorAttributes.gravatarID];
        
        if (gravatarImage) {
            cell.gravatarImageView.image = gravatarImage;
            [cell.activityIndicatorView stopAnimating];
        } else {
            [cell.activityIndicatorView startAnimating];
            
            [UIImage imageFromGravatarID:item.actorAttributes.gravatarID 
                   withCompletionHandler:^(UIImage *image, NSError *error, BOOL didDownload) {
                       [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] 
                                             withRowAnimation:UITableViewRowAnimationNone];
                   }];
            
        }

        NSUInteger numberOfCommits = [payload.commits count];
        
        cell.titleLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@ pushed to %@ (%d)", @""), item.actor, payload.branch, numberOfCommits];
        
        cell.repositoryLabel.text = payload.repo;
        
        if (numberOfCommits > 0) {
            GHCommitMessage *commit = [payload.commits objectAtIndex:0];
            cell.firstCommitLabel.text = commit.message;
        } else {
            cell.firstCommitLabel.text = nil;
        }
        
        if (numberOfCommits > 1) {
            GHCommitMessage *commit = [payload.commits objectAtIndex:1];
            cell.secondCommitLabel.text = commit.message;
        } else {
            cell.secondCommitLabel.text = nil;
        }
        
        return cell;
    }
    
    NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    if (item.payload.type == GHPayloadTypePullRequest) {
        cell.textLabel.text = @"Pull Request";
    } else if (item.payload.type == GHPayloadTypePush) {
        cell.textLabel.text = @"Pushed";
    } else {
        cell.textLabel.text = [NSString stringWithFormat:@"Unknown: %@", item.type];
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
    
    CGFloat height = 0.0;
    CGFloat minimumHeight = 0.0;
    
    if (item.payload.type == GHPayloadTypeIssue) {
        minimumHeight = 78.0;
        // this is the height for an issue cell, we will display the whole issue
        GHIssuePayload *payload = (GHIssuePayload *)item.payload;
        
        if ([GHIssue isIssueAvailableForRepository:payload.repo withNumber:payload.number]) {
            GHIssue *issue = [GHIssue issueFromDatabaseOnRepository:payload.repo withNumber:payload.number];
            
            CGSize newLabelSize = [issue.title sizeWithFont:[UIFont systemFontOfSize:12.0] 
                                          constrainedToSize:CGSizeMake(222.0f, MAXFLOAT)
                                              lineBreakMode:UILineBreakModeWordWrap];
            
            if (newLabelSize.height < 21) {
                newLabelSize.height = 21;
            }
            
            height = newLabelSize.height + 20.0 + 30.0; // X + top offset of status label + 30 px white space on the bottom
        } else {
            height = [GHIssueFeedItemTableViewCell height];
        }
    } else if (item.payload.type == GHPayloadTypePush) {
        minimumHeight = 78.0;
        GHPushPayload *payload = (GHPushPayload *)item.payload;
        // this is a commit / push message, we will display max 2 commits
        CGFloat commitHeight = 0.0;
        
        NSUInteger numberOfCommits = [payload.commits count];
        
        if (numberOfCommits > 0) {
            GHCommitMessage *commit = [payload.commits objectAtIndex:0];
            CGSize firstCommitSize = [commit.message sizeWithFont:[GHPushFeedItemTableViewCell commitFont] 
                                                            constrainedToSize:CGSizeMake(222.0f, MAXFLOAT)
                                                                lineBreakMode:UILineBreakModeWordWrap];
            if (firstCommitSize.height > [GHPushFeedItemTableViewCell maxCommitHeight]) {
                firstCommitSize.height = [GHPushFeedItemTableViewCell maxCommitHeight];
            }
            
            commitHeight += firstCommitSize.height;
        }
        
        
        
        if (numberOfCommits > 1) {
            GHCommitMessage *commit = [payload.commits objectAtIndex:1];
            CGSize secondCommitSize = [commit.message sizeWithFont:[GHPushFeedItemTableViewCell commitFont] 
                                                 constrainedToSize:CGSizeMake(222.0f, MAXFLOAT)
                                                     lineBreakMode:UILineBreakModeWordWrap];
            if (secondCommitSize.height > [GHPushFeedItemTableViewCell maxCommitHeight]) {
                secondCommitSize.height = [GHPushFeedItemTableViewCell maxCommitHeight];
            }
            
            commitHeight += secondCommitSize.height;
            commitHeight += 7.0;
        }

        height = 20.0 + commitHeight + 30.0;
    } else {
        minimumHeight = 55.0;
    }
    
    return height < minimumHeight ? minimumHeight : height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
}

@end
