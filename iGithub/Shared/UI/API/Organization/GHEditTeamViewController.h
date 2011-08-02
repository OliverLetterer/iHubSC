//
//  GHEditTeamViewController.h
//  iGithub
//
//  Created by Oliver Letterer on 02.08.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GHCreateTeamViewController.h"

@interface GHEditTeamViewController : GHCreateTeamViewController {
@private
    GHAPITeamV3 *_team;
    
    BOOL _didUpdateFirstCell;
}

@property (nonatomic, retain) GHAPITeamV3 *team;

- (id)initWithTeam:(GHAPITeamV3 *)team organization:(NSString *)organization;

@end
