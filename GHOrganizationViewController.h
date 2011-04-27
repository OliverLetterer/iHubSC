//
//  GHOrganizationViewController.h
//  iGithub
//
//  Created by Oliver Letterer on 27.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GHTableViewController.h"
#import "GithubAPI.h"

@interface GHOrganizationViewController : GHTableViewController {
@private
    NSString *_organizationLogin;
    
    GHOrganization *_organization;
    NSArray *_publicRepositories;
    NSArray *_publicMembers;
}

@property (nonatomic, copy) NSString *organizationLogin;
@property (nonatomic, retain) GHOrganization *organization;
@property (nonatomic, retain) NSArray *publicRepositories;
@property (nonatomic, retain) NSArray *publicMembers;

- (id)initWithOrganizationLogin:(NSString *)organizationLogin;;

@end
