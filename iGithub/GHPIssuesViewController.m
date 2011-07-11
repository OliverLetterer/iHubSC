//
//  GHPIssuesViewController.m
//  iGithub
//
//  Created by Oliver Letterer on 04.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHPIssuesViewController.h"
#import "GHPImageDetailTableViewCell.h"
#import "GHPIssueViewController.h"

@implementation GHPIssuesViewController

@synthesize repository=_repository;

#pragma mark - setters and getters

- (NSString *)emptyArrayErrorMessage {
    return NSLocalizedString(@"No Issues available", @"");
}

#pragma mark - Initialization

- (id)initWithRepository:(NSString *)repository {
    if (self = [super initWithStyle:UITableViewStyleGrouped]) {
        self.repository = repository;
    }
    return self;
}

#pragma mark - Memory management

- (void)dealloc {
    [_repository release];
    
    [super dealloc];
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"GHPImageDetailTableViewCell";
    
    GHPImageDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[GHPImageDetailTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    [self setupDefaultTableViewCell:cell forRowAtIndexPath:indexPath];
    
    GHAPIIssueV3 *issue = [self.dataArray objectAtIndex:indexPath.row];
    
    [self updateImageView:cell.imageView atIndexPath:indexPath withAvatarURLString:issue.user.avatarURL];
    cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@ (%@ ago)", @""), issue.user.login, issue.createdAt.prettyTimeIntervalSinceNow];
    cell.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Issue %@ - %@", @""), issue.number, issue.title];
    
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
    GHAPIIssueV3 *issue = [self.dataArray objectAtIndex:indexPath.row];
    
    GHPIssueViewController *viewController = [[[GHPIssueViewController alloc] initWithIssueNumber:issue.number onRepository:self.repository] autorelease];
    
    [self.advancedNavigationController pushViewController:viewController afterViewController:self];
}

#pragma mark - height caching

- (void)cacheDataArrayHeights {
    [self.dataArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        GHAPIIssueV3 *issue = obj;
        NSString *content = [NSString stringWithFormat:NSLocalizedString(@"Issue %@ - %@", @""), issue.number, issue.title];
        [self cacheHeight:[GHPImageDetailTableViewCell heightWithContent:content] forRowAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0] ];
    }];
}

@end
