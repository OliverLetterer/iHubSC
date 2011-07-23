//
//  GHPTeamsViewController.m
//  iGithub
//
//  Created by Oliver Letterer on 11.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHPTeamsViewController.h"
#import "GHPTeamViewController.h"

@implementation GHPTeamsViewController
@synthesize organizationName=_organizationName;

#pragma mark - setters and getters

- (NSString *)emptyArrayErrorMessage {
    return NSLocalizedString(@"No Teams available", @"");
}

#pragma mark - Initialization

- (id)initWithOrganizationName:(NSString *)organizationName {
    if (self = [super initWithStyle:UITableViewStyleGrouped]) {
        self.organizationName = organizationName;
    }
    return self;
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"GHPDefaultTableViewCell";
    GHPDefaultTableViewCell *cell = [self defaultTableViewCellForRowAtIndexPath:indexPath withReuseIdentifier:CellIdentifier];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    GHAPITeamV3 *team = [self.dataArray objectAtIndex:indexPath.row];
    cell.textLabel.text = team.name;
    
    return cell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    GHAPITeamV3 *team = [self.dataArray objectAtIndex:indexPath.row];
    GHPTeamViewController *viewController = [[[GHPTeamViewController alloc] initWithTeamID:team.ID] autorelease];
    [self.advancedNavigationController pushViewController:viewController afterViewController:self animated:YES];
}

#pragma mark - Memory management

- (void)dealloc {
    [_organizationName release];
    
    [super dealloc];
}

#pragma mark - Keyed Archiving

- (void)encodeWithCoder:(NSCoder *)encoder {
    [super encodeWithCoder:encoder];
    [encoder encodeObject:_organizationName forKey:@"organizationName"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super initWithCoder:decoder])) {
        _organizationName = [[decoder decodeObjectForKey:@"organizationName"] retain];
    }
    return self;
}

@end
