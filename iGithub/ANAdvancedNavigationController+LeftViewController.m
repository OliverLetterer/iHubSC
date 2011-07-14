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

- (void)_removeLeftViewControllerView {
    if (self.isViewLoaded) {
        [_leftViewController viewWillDisappear:NO];
        [_leftViewController.view removeFromSuperview];
        [_leftViewController viewDidDisappear:NO];
    }
}

- (void)_removeLeftViewController {
    [_leftViewController willMoveToParentViewController:nil];
    if (self.isViewLoaded) {
        [self _removeLeftViewControllerView];
    }
    [_leftViewController removeFromParentViewController];
    [_leftViewController release], _leftViewController = nil;
}

- (void)_setLeftViewController:(UIViewController *)leftViewController {
    [self _removeLeftViewController];
    
    if (leftViewController != nil) {
        _leftViewController = [leftViewController retain];
        [self addChildViewController:leftViewController];
        if (self.isViewLoaded) {
            [self _insertLeftViewControllerView];
        }
        [_leftViewController didMoveToParentViewController:self];
    }
}

- (void)_insertLeftViewControllerView {
    if (self.isViewLoaded) {
        _leftViewController.view.frame = CGRectMake(0.0f, 0.0f, ANAdvancedNavigationControllerDefaultLeftViewControllerWidth, CGRectGetHeight(self.view.bounds));
        _leftViewController.view.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        [self.view addSubview:_leftViewController.view];
    }
}

@end
