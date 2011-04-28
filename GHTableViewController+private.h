//
//  GHTableViewController+private.h
//  iGithub
//
//  Created by Oliver Letterer on 27.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GHTableViewController.h"

@interface GHTableViewController (GHTableViewControllerPrivate) <GHTableViewControllerAlertViewProxyDelegate>

@property (nonatomic, retain) GHTableViewControllerAlertViewProxy *alertProxy;

@end
