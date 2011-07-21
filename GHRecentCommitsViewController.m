//
//  GHRecentCommitsViewController.m
//  iGithub
//
//  Created by Oliver Letterer on 17.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHRecentCommitsViewController.h"
#import "GithubAPI.h"
#import "GHDescriptionTableViewCell.h"
#import "GHViewCommitViewController.h"

@implementation GHRecentCommitsViewController

@synthesize repository=_repository, branch=_branch, commits=_commits, branchHash=_branchHash;

#pragma mark - Initialization

- (id)initWithRepository:(NSString *)repository branch:(NSString *)branch {
    if ((self = [super initWithStyle:UITableViewStylePlain])) {
        // Custom initialization
        self.title = NSLocalizedString(@"Recent Commits", @"");
        self.repository = repository;
        self.branch = branch;
        self.isDownloadingEssentialData = YES;
        [self downloadCommitData];
    }
    return self;
}

#pragma mark - Memory management

- (void)dealloc {
    [_repository release];
    [_branch release];
    [_commits release];
    [_branchHash release];
    
    [super dealloc];
}

#pragma mark - pagination

- (void)downloadDataForPage:(NSUInteger)page inSection:(NSUInteger)section {
    [GHAPIRepositoryV3 commitsOnRepository:self.repository branchSHA:self.branchHash page:page 
                         completionHandler:^(NSMutableArray *array, NSUInteger nextPage, NSError *error) {
                             if (error) {
                                 [self handleError:error];
                             } else {
                                 [self setNextPage:nextPage forSection:0];
                                 [self.commits addObjectsFromArray:array];
                                 [self cacheHeightsForCommits];
                                 [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:section] 
                                               withRowAnimation:UITableViewRowAnimationAutomatic];
                             }
                         }];
}

#pragma mark - downloading data

- (void)downloadCommitData {
    [GHAPIRepositoryV3 commitsOnRepository:self.repository branchSHA:self.branchHash page:1 
                         completionHandler:^(NSMutableArray *array, NSUInteger nextPage, NSError *error) {
                             self.isDownloadingEssentialData = NO;
                             if (error) {
                                 [self handleError:error];
                             } else {
                                 [self setNextPage:nextPage forSection:0];
                                 self.commits = array;
                                 [self cacheHeightsForCommits];
                                 [self.tableView reloadData];
                             }
                         }];
}

- (void)cacheHeightsForCommits {
    NSInteger i = 0;
    for (GHAPICommitV3 *commit in self.commits) {
        CGFloat height = [self heightForDescription:commit.message] + 50.0;
        if (height < 71.05) {
            height = 71.0f;
        }
        [self cacheHeight:height forRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] ];
        i++;
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (!self.commits) {
        return 0;
    }
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.commits count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *CellIdentifier = @"GHFeedItemWithDescriptionTableViewCell";
    GHDescriptionTableViewCell *cell = (GHDescriptionTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[[GHDescriptionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    GHAPICommitV3 *commit = [self.commits objectAtIndex:indexPath.row];
    
    [self updateImageView:cell.imageView atIndexPath:indexPath withAvatarURLString:commit.author.avatarURL];
    
    cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@ committed %@", @""), commit.author.login, commit.SHA];
    cell.descriptionLabel.text = commit.message;
    
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
    GHAPICommitV3 *commit = [self.commits objectAtIndex:indexPath.row];
    
    GHViewCommitViewController *commitViewController = [[[GHViewCommitViewController alloc] initWithRepository:self.repository 
                                                                                                      commitID:commit.SHA]
                                                        autorelease];
    commitViewController.branchHash = self.branchHash;
    [self.navigationController pushViewController:commitViewController animated:YES];
}

#pragma mark Keyed Archiving

- (void)encodeWithCoder:(NSCoder *)encoder {
    [super encodeWithCoder:encoder];
    [encoder encodeObject:_repository forKey:@"repository"];
    [encoder encodeObject:_branch forKey:@"branch"];
    [encoder encodeObject:_branchHash forKey:@"branchHash"];
    [encoder encodeObject:_commits forKey:@"commits"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super initWithCoder:decoder])) {
        _repository = [[decoder decodeObjectForKey:@"repository"] retain];
        _branch = [[decoder decodeObjectForKey:@"branch"] retain];
        _branchHash = [[decoder decodeObjectForKey:@"branchHash"] retain];
        _commits = [[decoder decodeObjectForKey:@"commits"] retain];
    }
    return self;
}

@end
