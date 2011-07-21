//
//  GHSearchUserViewController.m
//  iGithub
//
//  Created by Oliver Letterer on 20.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHSearchUserViewController.h"
#import "GHDescriptionTableViewCell.h"
#import "GithubAPI.h"
#import "GHUserViewController.h"

@implementation GHSearchUserViewController

@synthesize users=_users, searchString=_searchString;

#pragma mark - setters and getters

- (void)setSearchString:(NSString *)searchString {
    [_searchString release], _searchString = [searchString copy];
    
    self.users = nil;
    
    self.isDownloadingEssentialData = YES;
    [GHUser searchUsersWithSearchString:self.searchString
                      completionHandler:^(NSArray *users, NSError *error) {
                          self.isDownloadingEssentialData = NO;
                          if (error) {
                              [self handleError:error];
                          } else {
                              self.users = users;
                              if (self.isViewLoaded) {
                                  [self.tableView reloadData];
                              }
                          }
                      }];
}

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

#pragma mark - Memory management

- (void)dealloc {
    [_users release];
    [_searchString release];
    
    [super dealloc];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (!self.users) {
        return 0;
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.users count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *CellIdentifier = @"GHFeedItemWithDescriptionTableViewCell";
    
    GHDescriptionTableViewCell *cell = (GHDescriptionTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[GHDescriptionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    GHUser *user = [self.users objectAtIndex:indexPath.row];
    
    cell.textLabel.text = user.login;
    cell.descriptionLabel.text = nil;
    
    cell.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Since %@", @""), user.createdAt.prettyTimeIntervalSinceNow];
    
    [self updateImageView:cell.imageView atIndexPath:indexPath withGravatarID:user.gravatarID];
    
    // Configure the cell...
    
    return cell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 71.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    GHUser *user = [self.users objectAtIndex:indexPath.row];
    
    GHUserViewController *userViewController = [[[GHUserViewController alloc] initWithUsername:user.login] autorelease];
    [self.navigationController pushViewController:userViewController animated:YES];
}

#pragma mark Keyed Archiving

- (void)encodeWithCoder:(NSCoder *)encoder {
    [super encodeWithCoder:encoder];
    [encoder encodeObject:_searchString forKey:@"searchString"];
    [encoder encodeObject:_users forKey:@"users"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super initWithCoder:decoder])) {
        _searchString = [[decoder decodeObjectForKey:@"searchString"] retain];
        _users = [[decoder decodeObjectForKey:@"users"] retain];
    }
    return self;
}

@end
