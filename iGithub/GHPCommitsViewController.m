//
//  GHPCommitsViewController.m
//  iGithub
//
//  Created by Oliver Letterer on 02.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHPCommitsViewController.h"
#import "GHPImageDetailTableViewCell.h"
#import "GHPCommitViewController.h"

@implementation GHPCommitsViewController

@synthesize repository=_repository, branchHash=_branchHash;

#pragma mark - setters and getters

- (NSString *)emptyArrayErrorMessage {
    return NSLocalizedString(@"No Commits available", @"");
}

- (void)setRepository:(NSString *)repository branchHash:(NSString *)branchHash {
    [_repository release], _repository = [repository copy];
    [_branchHash release], _branchHash = [branchHash copy];
    
    [GHAPIRepositoryV3 commitsOnRepository:self.repository branchSHA:self.branchHash page:1 
                         completionHandler:^(NSMutableArray *array, NSUInteger nextPage, NSError *error) {
                             self.isDownloadingEssentialData = NO;
                             if (error) {
                                 [self handleError:error];
                             } else {
                                 [self setDataArray:array nextPage:nextPage];
                             }
                         }];
}

#pragma mark - Pagination

- (void)downloadDataForPage:(NSUInteger)page inSection:(NSUInteger)section {
    [GHAPIRepositoryV3 commitsOnRepository:self.repository branchSHA:self.branchHash page:page 
                         completionHandler:^(NSMutableArray *array, NSUInteger nextPage, NSError *error) {
                             if (error) {
                                 [self handleError:error];
                             } else {
                                 [self appendDataFromArray:array nextPage:nextPage];
                             }
                         }];
}

#pragma mark - Initialization

- (id)initWithRepository:(NSString *)repository branchHash:(NSString *)branchHash {
    if ((self = [super initWithStyle:UITableViewStyleGrouped])) {
        // Custom initialization
        [self setRepository:repository branchHash:branchHash];
    }
    return self;
}

#pragma mark - Memory management

- (void)dealloc {
    [_repository release];
    [_branchHash release];
    
    [super dealloc];
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *CellIdentifier = @"GHPImageDetailTableViewCell";
    
    GHPImageDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[GHPImageDetailTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    [self setupDefaultTableViewCell:cell forRowAtIndexPath:indexPath];
    
    GHAPICommitV3 *commit = [self.dataArray objectAtIndex:indexPath.row];
    
    [self updateImageView:cell.imageView atIndexPath:indexPath withGravatarID:commit.committer.gravatarID];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ - %@", commit.committer.login, commit.SHA];
    cell.detailTextLabel.text = commit.message;
    
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
    GHAPICommitV3 *commit = [self.dataArray objectAtIndex:indexPath.row];
    
    GHPCommitViewController *commitViewController = [[[GHPCommitViewController alloc] initWithRepository:self.repository 
                                                                                                commitID:commit.SHA]
                                                     autorelease];
    [self.advancedNavigationController pushViewController:commitViewController afterViewController:self];
}

#pragma mark - height caching

- (void)cacheDataArrayHeights {
    [self.dataArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        GHAPICommitV3 *commit = obj;
        
        [self cacheHeight:[GHPImageDetailTableViewCell heightWithContent:commit.message] forRowAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0] ];
    }];
}

@end
