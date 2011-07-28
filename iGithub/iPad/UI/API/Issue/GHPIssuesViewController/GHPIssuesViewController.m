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

@synthesize repository=_repository, username=_username;

#pragma mark - setters and getters

- (NSString *)emptyArrayErrorMessage {
    return NSLocalizedString(@"No Issues available", @"");
}

- (NSString *)descriptionStringForIssue:(GHAPIIssueV3 *)issue {
    return [NSString stringWithFormat:NSLocalizedString(@"Issue %@ - %@", @""), issue.number, issue.title];
}

#pragma mark - Initialization

- (id)initWithRepository:(NSString *)repository {
    if (self = [super initWithStyle:UITableViewStyleGrouped]) {
        self.repository = repository;
    }
    return self;
}

- (id)initWithUsername:(NSString *)username {
    if (self = [super initWithStyle:UITableViewStyleGrouped]) {
        self.username = username;
    }
    return self;
}

#pragma mark - Memory management


#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"GHPImageDetailTableViewCell";
    
    GHPImageDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[GHPImageDetailTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    [self setupDefaultTableViewCell:cell forRowAtIndexPath:indexPath];
    
    GHAPIIssueV3 *issue = [self.dataArray objectAtIndex:indexPath.row];
    
    [self updateImageView:cell.imageView atIndexPath:indexPath withAvatarURLString:issue.user.avatarURL];
    cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@ (%@ ago)", @""), issue.user.login, issue.createdAt.prettyTimeIntervalSinceNow];
    cell.detailTextLabel.text = [self descriptionStringForIssue:issue];
    
    // Configure the cell...
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    GHAPIIssueV3 *issue = [self.dataArray objectAtIndex:indexPath.row];
    
    GHPIssueViewController *viewController = [[GHPIssueViewController alloc] initWithIssueNumber:issue.number onRepository:issue.repository];
    
    [self.advancedNavigationController pushViewController:viewController afterViewController:self animated:YES];
}

#pragma mark - height caching

- (void)cacheDataArrayHeights {
    [self.dataArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        GHAPIIssueV3 *issue = obj;
        NSString *content = [self descriptionStringForIssue:issue];
        [self cacheHeight:[GHPImageDetailTableViewCell heightWithContent:content] forRowAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0] ];
    }];
}

#pragma mark - Keyed Archiving

- (void)encodeWithCoder:(NSCoder *)encoder {
    [super encodeWithCoder:encoder];
    [encoder encodeObject:_repository forKey:@"repository"];
    [encoder encodeObject:_username forKey:@"username"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super initWithCoder:decoder])) {
        _repository = [decoder decodeObjectForKey:@"repository"];
        _username = [decoder decodeObjectForKey:@"username"];
    }
    return self;
}

@end
