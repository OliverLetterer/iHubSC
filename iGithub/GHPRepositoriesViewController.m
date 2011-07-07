//
//  GHPRepositoriesViewController.m
//  iGithub
//
//  Created by Oliver Letterer on 01.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHPRepositoriesViewController.h"
#import "GHPRepositoryTableViewCell.h"
#import "GHPRepositoryViewController.h"

@implementation GHPRepositoriesViewController

@synthesize username=_username;

#pragma mark - setters and getters

- (NSString *)emptyArrayErrorMessage {
    return NSLocalizedString(@"No Repositories available", @"");
}

#pragma mark - Initialization

- (id)initWithUsername:(NSString *)username {
    if ((self = [super initWithStyle:UITableViewStyleGrouped])) {
        // Custom initialization
        self.username = username;
    }
    return self;
}

#pragma mark - Memory management

- (void)dealloc {
    [_username release];
    
    [super dealloc];
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    GHPRepositoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[[GHPRepositoryTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    GHAPIRepositoryV3 *repository = [self.dataArray objectAtIndex:indexPath.row];
    
    cell.textLabel.text = repository.fullRepositoryName;
    cell.detailTextLabel.text = repository.description;
    
    if ([repository.private boolValue]) {
        cell.imageView.image = [UIImage imageNamed:@"GHPrivateRepositoryIcon.png"];
    } else {
        cell.imageView.image = [UIImage imageNamed:@"GHPublicRepositoryIcon.png"];
    }
    
    [self setupDefaultTableViewCell:cell forRowAtIndexPath:indexPath];
    
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
    GHAPIRepositoryV3 *repository = [self.dataArray objectAtIndex:indexPath.row];
    GHPRepositoryViewController *repoViewController = [[[GHPRepositoryViewController alloc] initWithRepositoryString:repository.fullRepositoryName] autorelease];
    [self.advancedNavigationController pushViewController:repoViewController afterViewController:self];
}

#pragma mark - caching height

- (void)cacheDataArrayHeights {
    [self.dataArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        GHAPIRepositoryV3 *repository = obj;
        
        [self cacheHeight:[GHPRepositoryTableViewCell heightWithContent:repository.description] 
        forRowAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0] ];
    }];
}

@end
