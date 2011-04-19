//
//  UIViewController+GHErrorHandling.h
//  iGithub
//
//  Created by Oliver Letterer on 18.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GHAuthenticationViewController.h"

@interface UIViewController (GHViewControllerErrorhandling) <GHAuthenticationViewControllerDelegate>

- (void)handleError:(NSError *)error;

@end
