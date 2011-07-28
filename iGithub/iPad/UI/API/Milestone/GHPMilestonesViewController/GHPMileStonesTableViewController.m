//
//  GHPMileStonesTableViewController.m
//  iGithub
//
//  Created by Oliver Letterer on 05.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHPMileStonesTableViewController.h"
#import "GHPMileStoneTableViewCell.h"
#import "GHPMilestoneViewController.h"

@implementation GHPMileStonesTableViewController

@synthesize repository=_repository;

#pragma mark - setters and getters

- (NSString *)emptyArrayErrorMessage {
    return NSLocalizedString(@"No Milestones available", @"");
}

#pragma mark - Initialization

- (id)initWithRepository:(NSString *)repository {
    if ((self = [super initWithStyle:UITableViewStyleGrouped])) {
        // Custom initialization
        self.repository = repository;
    }
    return self;
}

#pragma mark - Memory management


#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"GHPMileStoneTableViewCell";
    
    GHPMileStoneTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[GHPMileStoneTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    [self setupDefaultTableViewCell:cell forRowAtIndexPath:indexPath];
    
    GHAPIMilestoneV3 *milestone = [self.dataArray objectAtIndex:indexPath.row];
    
    cell.progressView.progress = milestone.progress;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Milestone %@", @""), milestone.title];
    cell.detailTextLabel.text = milestone.dueFormattedString;
    
    if (milestone.dueInTime) {
        [cell.progressView setTintColor:[UIColor greenColor] ];
    } else {
        [cell.progressView setTintColor:[UIColor redColor] ];
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return GHPMileStoneTableViewCellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    GHAPIMilestoneV3 *milestone = [self.dataArray objectAtIndex:indexPath.row];
    
    GHPMilestoneViewController *viewController = [[GHPMilestoneViewController alloc] initWithRepository:self.repository milestoneNumber:milestone.number];
    
    [self.advancedNavigationController pushViewController:viewController afterViewController:self animated:YES];
}

#pragma mark - Keyed Archiving

- (void)encodeWithCoder:(NSCoder *)encoder {
    [super encodeWithCoder:encoder];
    [encoder encodeObject:_repository forKey:@"repository"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super initWithCoder:decoder])) {
        _repository = [decoder decodeObjectForKey:@"repository"];
    }
    return self;
}

@end
