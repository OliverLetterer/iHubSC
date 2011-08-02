//
//  GHCreateTeamViewController.h
//  iGithub
//
//  Created by Oliver Letterer on 01.08.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GHTableViewController.h"
#import "GHTextFieldTableViewCell.h"
#import "GHPTextFieldTableViewCell.h"

@class GHCreateTeamViewController;

@protocol GHCreateTeamViewControllerDelegate <NSObject>

- (void)createTeamViewController:(GHCreateTeamViewController *)createViewController didCreateTeam:(GHAPITeamV3 *)team;
- (void)createTeamViewControllerDidCancel:(GHCreateTeamViewController *)createViewController;

@end



NSString *NSStringFromGHAPITeamPermissionV3(NSString *GHAPITeamPermissionV3);

extern NSInteger const kGHCreateTeamViewControllerTableViewSectionTitle;
extern NSInteger const kGHCreateTeamViewControllerTableViewSectionPermission;
extern NSInteger const kGHCreateTeamViewControllerTableViewSectionRepositories;
extern NSInteger const kGHCreateTeamViewControllerTableViewSectionMembers;

@interface GHCreateTeamViewController : GHTableViewController {
@private
    id<GHCreateTeamViewControllerDelegate> __weak _delegate;
    NSString *_organization;
    
    NSArray *_availablePermissions;
    NSString *_selectedPermission;
    
    NSMutableArray *_repositories;
    NSMutableArray *_selectedRepositories;
    
    NSMutableArray *_members;
    NSMutableArray *_selectedMembers;
}

@property (nonatomic, weak) id<GHCreateTeamViewControllerDelegate> delegate;
@property (nonatomic, copy) NSString *organization;

@property (nonatomic, readonly) NSArray *availablePermissions;
@property (nonatomic, copy) NSString *selectedPermission;
@property (nonatomic, readonly) NSMutableArray *selectedRepositories;
@property (nonatomic, readonly) NSMutableArray *selectedMembers;



- (id)initWithOrganization:(NSString *)organization;

- (void)cancelButtonClicked:(UIBarButtonItem *)sender;
- (void)saveButtonClicked:(UIBarButtonItem *)sender;

@end
