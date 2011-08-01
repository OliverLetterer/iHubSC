//
//  GHCreateTeamViewController.h
//  iGithub
//
//  Created by Oliver Letterer on 01.08.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GHTableViewController.h"

@class GHCreateTeamViewController;

@protocol GHCreateTeamViewControllerDelegate <NSObject>

- (void)createTeamViewController:(GHCreateTeamViewController *)createViewController didCreateTeam:(GHAPITeamV3 *)team;
- (void)createTeamViewControllerDidCancel:(GHCreateTeamViewController *)createViewController;

@end



@interface GHCreateTeamViewController : GHTableViewController {
@private
    id<GHCreateTeamViewControllerDelegate> __weak _delegate;
    NSString *_organization;
}

@property (nonatomic, weak) id<GHCreateTeamViewControllerDelegate> delegate;
@property (nonatomic, copy) NSString *organization;

- (id)initWithOrganization:(NSString *)organization;

- (void)cancelButtonClicked:(UIBarButtonItem *)sender;
- (void)saveButtonClicked:(UIBarButtonItem *)sender;

@end
