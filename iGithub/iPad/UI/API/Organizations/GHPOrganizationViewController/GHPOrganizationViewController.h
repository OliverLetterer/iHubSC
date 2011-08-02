//
//  GHPOrganizationViewController.h
//  iGithub
//
//  Created by Oliver Letterer on 11.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GHPInfoSectionTableViewController.h"
#import <MessageUI/MessageUI.h>
#import "GHCreateTeamViewController.h"

@interface GHPOrganizationViewController : GHPInfoSectionTableViewController <MFMailComposeViewControllerDelegate, UIAlertViewDelegate, NSCoding, GHCreateTeamViewControllerDelegate> {
@private
    NSString *_organizationName;
    GHAPIOrganizationV3 *_organization;
    
    BOOL _hasAdminData;
    BOOL _isAdmin;
}

@property (nonatomic, copy) NSString *organizationName;
@property (nonatomic, retain) GHAPIOrganizationV3 *organization;

@property (nonatomic, readonly) NSString *infoDetailsString;

- (id)initWithOrganizationName:(NSString *)organizationName;

@end
