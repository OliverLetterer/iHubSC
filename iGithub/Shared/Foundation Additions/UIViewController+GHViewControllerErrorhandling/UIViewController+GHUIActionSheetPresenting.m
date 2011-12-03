//
//  UIViewController+GHUIActionSheetPresenting.m
//  iGithub
//
//  Created by Oliver Letterer on 03.12.11.
//  Copyright (c) 2011 Home. All rights reserved.
//

#import "UIViewController+GHUIActionSheetPresenting.h"



@implementation UIViewController (GHUIActionSheetPresenting)

- (void)presentActionSheetFromParentViewController:(UIActionSheet *)actionSheet
{
    UIViewController *highestViewController = self;
    
    while (highestViewController.parentViewController) {
        highestViewController = highestViewController.parentViewController;
    }
    
    [actionSheet showInView:highestViewController.view];
}

@end
