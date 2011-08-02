//
//  GHPTeamViewController.h
//  iGithub
//
//  Created by Oliver Letterer on 11.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GHPInfoSectionTableViewController.h"
#import "GHEditTeamViewController.h"

@interface GHPTeamViewController : GHPInfoSectionTableViewController <NSCoding, GHCreateTeamViewControllerDelegate> {
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
@property (nonatomic, retain) NSMutableArray *members;
@property (nonatomic, retain) NSMutableArray *repositories;
@property (nonatomic, copy) NSString *organization;

- (id)initWithTeamID:(NSNumber *)teamID organization:(NSString *)organization;

@end
