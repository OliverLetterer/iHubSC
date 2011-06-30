//
//  ANAdvancedNavigationController+LeftViewController.m
//  ANAdvancedNavigationController
//
//  Created by Oliver Letterer on 28.06.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ANAdvancedNavigationController+LeftViewController.h"
#import "ANAdvancedNavigationController+private.h"

@implementation ANAdvancedNavigationController (ANAdvancedNavigationController_LeftViewController)

- (void)replaceLeftViewControllerWithViewController:(UIViewController *)leftViewController {
    if (self.isViewLoaded) {
        // view is Loaded, need to exchange views
        [_leftViewController.view removeFromSuperview];
        [_leftViewController removeFromParentViewController];
        
        [self loadAndPrepareLeftViewController:leftViewController];
    }
}

- (void)loadAndPrepareLeftViewController:(UIViewController *)leftViewController {
    leftViewController.view.frame = CGRectMake(0.0f, 0.0f, ANAdvancedNavigationControllerDefaultLeftViewControllerWidth, CGRectGetHeight(self.view.bounds));
    leftViewController.view.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:leftViewController.view];
    [self addChildViewController:leftViewController];
}

@end
