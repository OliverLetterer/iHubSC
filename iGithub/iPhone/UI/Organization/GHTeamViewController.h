//
//  GHTeamViewController.h
//  iGithub
//
//  Created by Oliver Letterer on 27.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GithubAPI.h"
#import "GHActionButtonTableViewController.h"
#import "GHEditTeamViewController.h"

@interface GHTeamViewController : GHActionButtonTableViewController <GHCreateTeamViewControllerDelegate> {
@private
    GHAPITeamV3 *_team;
    NSNumber *_teamID;
    NSString *_organization;
    
    NSMutableArray *_members;
    NSMutableArray *_repositories;
    
    BOOL _hasAdminData;
    BOOL _isAdmin;
}

@property (nonatomic, retain) GHAPITeamV3 *team;
@property (nonatomic, copy) NSNumber *teamID;
@property (nonatomic, copy) NSString *organization;
@property (nonatomic, retain) NSMutableArray *members;
@property (nonatomic, retain) NSMutableArray *repositories;

- (id)initWithTeamID:(NSNumber *)teamID organization:(NSString *)organization;

@end
