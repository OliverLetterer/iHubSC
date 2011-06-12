//
//  GHTeamViewController.h
//  iGithub
//
//  Created by Oliver Letterer on 27.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GithubAPI.h"
#import "GHTableViewController.h"

@interface GHTeamViewController : GHTableViewController {
@private
    GHAPITeamV3 *_team;
    NSNumber *_teamID;
    
    NSMutableArray *_members;
    NSMutableArray *_repositories;
}

@property (nonatomic, retain) GHAPITeamV3 *team;
@property (nonatomic, copy) NSNumber *teamID;
@property (nonatomic, retain) NSMutableArray *members;
@property (nonatomic, retain) NSMutableArray *repositories;

- (id)initWithTeamID:(NSNumber *)teamID;

@end
