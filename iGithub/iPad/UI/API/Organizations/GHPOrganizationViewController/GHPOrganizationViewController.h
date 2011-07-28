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

@interface GHPOrganizationViewController : GHPInfoSectionTableViewController <MFMailComposeViewControllerDelegate, UIAlertViewDelegate, NSCoding> {
@private
    NSString *_organizationName;
    GHAPIOrganizationV3 *_organization;
}

@property (nonatomic, copy) NSString *organizationName;
@property (nonatomic, retain) GHAPIOrganizationV3 *organization;

@property (nonatomic, readonly) NSString *infoDetailsString;

- (id)initWithOrganizationName:(NSString *)organizationName;

@end
