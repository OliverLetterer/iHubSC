//
//  GHOrganizationViewController.h
//  iGithub
//
//  Created by Oliver Letterer on 27.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

#import "GHActionButtonTableViewController.h"
#import "GHCreateTeamViewController.h"

@interface GHOrganizationViewController : GHActionButtonTableViewController <GHCreateTeamViewControllerDelegate, MFMailComposeViewControllerDelegate> {
@private
    NSString *_organizationLogin;
    
    GHAPIOrganizationV3 *_organization;
    NSMutableArray *_publicRepositories;
    NSMutableArray *_publicMembers;
    NSMutableArray *_teams;
    
    BOOL _hasAdminData;
    BOOL _isAdmin;
}

@property (nonatomic, copy) NSString *organizationLogin;
@property (nonatomic, retain) GHAPIOrganizationV3 *organization;
@property (nonatomic, retain) NSMutableArray *publicRepositories;
@property (nonatomic, retain) NSMutableArray *publicMembers;
@property (nonatomic, retain) NSMutableArray *teams;

- (id)initWithOrganizationLogin:(NSString *)organizationLogin;;

@end
