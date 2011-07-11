//
//  UIViewController+GHErrorHandling.h
//  iGithub
//
//  Created by Oliver Letterer on 18.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIViewController (GHViewControllerErrorhandling)

- (void)handleError:(NSError *)error;
- (void)invalidadUserData;

@end
