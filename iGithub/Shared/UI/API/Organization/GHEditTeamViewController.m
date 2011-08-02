//
//  GHEditTeamViewController.m
//  iGithub
//
//  Created by Oliver Letterer on 02.08.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHEditTeamViewController.h"


@implementation GHEditTeamViewController
@synthesize team=_team;

#pragma mark - Initialization

- (id)initWithTeam:(GHAPITeamV3 *)team organization:(NSString *)organization {
    if ((self = [super initWithOrganization:organization])) {
        self.team = team;
        self.title = NSLocalizedString(@"Edit Team", @"");
        self.selectedPermission = team.permission;
        self.isDownloadingEssentialData = YES;
        [GHAPITeamV3 allMembersOfTeamWithID:team.ID completionHandler:^(NSMutableArray *members, NSError *error) {
            if (self.isViewLoaded) {
                [self.tableView reloadData];
            }
            if (error) {
                [self handleError:error];
            } else {
                for (GHAPIUserV3 *user in members) {
                    [self.selectedMembers addObject:user.login];
                }
                
                [GHAPITeamV3 allRepositoriesOfTeamWithID:team.ID completionHandler:^(NSMutableArray *repositories, NSError *error) {
                    if (error) {
                        [self handleError:error];
                    } else {
                        for (GHAPIRepositoryV3 *repository in repositories) {
                            [self.selectedRepositories addObject:repository.fullRepositoryName];
                        }
                    }
                    
                    self.isDownloadingEssentialData = NO;
                    if (self.isViewLoaded) {
                        [self.tableView reloadData];
                    }
                }];
            }
        }];
    }
    return self;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.isDownloadingEssentialData) {
        return 0;
    }
    // Return the number of sections.
    return [super numberOfSectionsInTableView:tableView];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    if (!_didUpdateFirstCell) {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            if ([cell isKindOfClass:GHPTextFieldTableViewCell.class]) {
                GHPTextFieldTableViewCell *issueCell = (GHPTextFieldTableViewCell *)cell;
                
                issueCell.textField.text = self.team.name;
            }
        } else {
            if ([cell isKindOfClass:GHTextFieldTableViewCell.class]) {
                GHTextFieldTableViewCell *issueCell = (GHTextFieldTableViewCell *)cell;
                
                issueCell.textField.text = self.team.name;
            }
        }
        _didUpdateFirstCell = YES;
    }
    
    return cell;
}

- (void)saveButtonClicked:(UIBarButtonItem *)sender {
    NSString *name = nil;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        GHPTextFieldTableViewCell *cell = (GHPTextFieldTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:kGHCreateTeamViewControllerTableViewSectionTitle] ];
        
        name = cell.textField.text;
    } else {
        GHTextFieldTableViewCell *cell = (GHTextFieldTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:kGHCreateTeamViewControllerTableViewSectionTitle] ];
        
        name = cell.textField.text;
    }
    
    [GHAPITeamV3 updateTeamWithID:self.team.ID teamMembers:_selectedMembers repositories:_selectedRepositories permission:_selectedPermission
                             name:name completionHandler:^(GHAPITeamV3 *team, NSError *error) {
                                 if (error) {
                                     [self handleError:error];
                                 } else {
                                     [self.delegate createTeamViewController:self didCreateTeam:team];
                                 }
                             }];
}

@end
