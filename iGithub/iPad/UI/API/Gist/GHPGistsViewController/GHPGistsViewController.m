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

#pragma mark - Notifications

- (void)gistDeletedNotificationCallback:(NSNotification *)notification {
    NSString *gistID = [notification.userInfo objectForKey:GHAPIV3NotificationUserDictionaryGistIDKey];
    NSIndexSet *deleteSet = [self.dataArray indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        GHAPIGistV3 *gist = obj;
        return [gist.ID isEqualToString:gistID];
    }];
    
    [self dataArrayRemoveObjectsInSet:deleteSet];
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"GHPRepositoryTableViewCell";
    
    GHPRepositoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[GHPRepositoryTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
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

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    GHAPIGistV3 *gist = [self.dataArray objectAtIndex:indexPath.row];
    GHPGistViewController *viewController = [[GHPGistViewController alloc] initWithGistID:gist.ID];
    
    [self.advancedNavigationController pushViewController:viewController afterViewController:self animated:YES];
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
