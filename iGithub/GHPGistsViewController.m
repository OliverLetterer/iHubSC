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

#pragma mark - setters and getters

- (NSString *)emptyArrayErrorMessage {
    return NSLocalizedString(@"No Gists available", @"");
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"GHPRepositoryTableViewCell";
    
    GHPRepositoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[GHPRepositoryTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    [self setupDefaultTableViewCell:cell forRowAtIndexPath:indexPath];
    
    GHAPIGistV3 *gist = [self.dataArray objectAtIndex:indexPath.row];
    
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    GHAPIGistV3 *gist = [self.dataArray objectAtIndex:indexPath.row];
    GHPGistViewController *viewController = [[[GHPGistViewController alloc] initWithGistID:gist.ID] autorelease];
    
    [self.advancedNavigationController pushViewController:viewController afterViewController:self];
}

#pragma mark - Height caching

- (void)cacheDataArrayHeights {
    [self.dataArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        GHAPIGistV3 *gist = obj;
        
        [self cacheHeight:[GHPRepositoryTableViewCell heightWithContent:gist.description] 
        forRowAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0]];
    }];
}

@end
