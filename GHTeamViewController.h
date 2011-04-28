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
    GHTeam *_team;
    
    NSMutableArray *_members;
    NSMutableArray *_repositories;
}

@property (nonatomic, retain) GHTeam *team;
@property (nonatomic, retain) NSMutableArray *members;
@property (nonatomic, retain) NSMutableArray *repositories;

- (id)initWithTeam:(GHTeam *)team;

@end
