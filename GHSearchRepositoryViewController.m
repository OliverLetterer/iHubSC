//
//  GHSearchRepositoryViewController.m
//  iGithub
//
//  Created by Oliver Letterer on 20.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHSearchRepositoryViewController.h"
#import "GithubAPI.h"
#import "GHFeedItemWithDescriptionTableViewCell.h"
#import "GHSingleRepositoryViewController.h"

@implementation GHSearchRepositoryViewController

@synthesize searchString=_searchString, repositories=_repositories;

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
    [_searchString release];
    [_repositories release];
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - instance methods

- (void)pullToReleaseTableViewReloadData {
    [super pullToReleaseTableViewReloadData];
    [GHRepository searchRepositoriesWithSearchString:self.searchString 
                                   completionHandler:^(NSArray *repos, NSError *error) {
                                       if (error) {
                                           [self handleError:error];
                                       } else {
                                           self.repositories = repos;
                                           [self cacheHeightForRepositories];
                                           [self.tableView reloadData];
                                       }
                                   }];
    [self pullToReleaseTableViewDidReloadData];
}

- (void)cacheHeightForRepositories {
    NSInteger i = 0;
    for (GHRepository *repo in self.repositories) {
        CGFloat height = [self heightForDescription:repo.desctiptionRepo] + 50.0;
        
        if (height < 71.0) {
            height = 71.0;
        }
        
        [self cacheHeight:height forRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        
        i++;
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.repositories count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *CellIdentifier = @"GHFeedItemWithDescriptionTableViewCell";
    
    GHFeedItemWithDescriptionTableViewCell *cell = (GHFeedItemWithDescriptionTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[GHFeedItemWithDescriptionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    GHRepository *repository = [self.repositories objectAtIndex:indexPath.row];
    
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
    GHRepository *repo = [self.repositories objectAtIndex:indexPath.row];
    
    GHSingleRepositoryViewController *viewController = [[[GHSingleRepositoryViewController alloc] initWithRepositoryString:[NSString stringWithFormat:@"%@/%@", repo.owner, repo.name] ] autorelease];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self cachedHeightForRowAtIndexPath:indexPath];
}

@end
