//
//  GHPOrganizationsViewController.m
//  iGithub
//
//  Created by Oliver Letterer on 11.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHPOrganizationsViewController.h"
#import "GHPUserTableViewCell.h"
#import "GHPOrganizationViewController.h"

@implementation GHPOrganizationsViewController

#pragma mark - setters and getters

- (NSString *)emptyArrayErrorMessage {
    return NSLocalizedString(@"No Organizations available", @"");
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"GHPUserTableViewCell";
    
    GHPUserTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[GHPUserTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    [self setupDefaultTableViewCell:cell forRowAtIndexPath:indexPath];
    
    GHAPIOrganizationV3 *organization = [self.dataArray objectAtIndex:indexPath.row];
    
    cell.textLabel.text = organization.login;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    [self updateImageView:cell.imageView atIndexPath:indexPath withAvatarURLString:organization.avatarURL];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    GHAPIOrganizationV3 *organization = [self.dataArray objectAtIndex:indexPath.row];
    
    GHPOrganizationViewController *viewController = [[[GHPOrganizationViewController alloc] initWithOrganizationName:organization.login] autorelease];
    [self.advancedNavigationController pushViewController:viewController afterViewController:self];
}

#pragma mark - Height caching

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return GHPUserTableViewCellHeight;
}

@end
