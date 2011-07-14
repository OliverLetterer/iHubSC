//
//  GHSearchUserViewController.m
//  iGithub
//
//  Created by Oliver Letterer on 20.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHSearchUserViewController.h"
#import "GHFeedItemWithDescriptionTableViewCell.h"
#import "GithubAPI.h"
#import "GHUserViewController.h"

@implementation GHSearchUserViewController

@synthesize users=_users, searchString=_searchString;

#pragma mark - Initialization

- (id)initWithSearchString:(NSString *)searchString {
    if ((self = [super initWithStyle:UITableViewStylePlain])) {
        // Custom initialization
        self.searchString = searchString;
        [self pullToReleaseTableViewReloadData];
        self.pullToReleaseEnabled = NO;
        self.title = self.searchString;
    }
    return self;
}

#pragma mark - instance methids

- (void)pullToReleaseTableViewReloadData {
    [super pullToReleaseTableViewReloadData];
    [GHUser searchUsersWithSearchString:self.searchString
                      completionHandler:^(NSArray *users, NSError *error) {
                          if (error) {
                              [self handleError:error];
                          } else {
                              self.users = users;
                              [self cacheHeightForRepositories];
                              [self.tableView reloadData];
                          }
                          [self pullToReleaseTableViewDidReloadData];
                      }];
}

- (void)cacheHeightForRepositories {
    NSInteger i = 0;
    for (GHUser *user in self.users) {
        CGFloat height = 0.0;//[self heightForDescription:repo.desctiptionRepo] + 50.0;
        
        if (height < 71.0) {
            height = 71.0;
        }
        
        [self cacheHeight:height forRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        
        i++;
    }
}

#pragma mark - Memory management

- (void)dealloc {
    [_users release];
    [_searchString release];
    
    [super dealloc];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.users count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *CellIdentifier = @"GHFeedItemWithDescriptionTableViewCell";
    
    GHFeedItemWithDescriptionTableViewCell *cell = (GHFeedItemWithDescriptionTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[GHFeedItemWithDescriptionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    GHUser *user = [self.users objectAtIndex:indexPath.row];
    
    cell.titleLabel.text = user.login;
    cell.descriptionLabel.text = nil;
    
    cell.repositoryLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Since %@", @""), user.createdAt.prettyTimeIntervalSinceNow];
    
    [self updateImageView:cell.imageView atIndexPath:indexPath withGravatarID:user.gravatarID];
    
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
    GHUser *user = [self.users objectAtIndex:indexPath.row];
    
    GHUserViewController *userViewController = [[[GHUserViewController alloc] initWithUsername:user.login] autorelease];
    [self.navigationController pushViewController:userViewController animated:YES];
}

@end
