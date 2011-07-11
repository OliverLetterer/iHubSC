//
//  GHPOrganizationViewController.h
//  iGithub
//
//  Created by Oliver Letterer on 11.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GHTableViewController.h"

@interface GHPOrganizationViewController : GHTableViewController {
@private
    NSString *_organizationName;
    GHAPIOrganizationV3 *_organization;
}

@property (nonatomic, copy) NSString *organizationName;
@property (nonatomic, retain) GHAPIOrganizationV3 *organization;

- (id)initWithOrganizationName:(NSString *)organizationName;

@end
