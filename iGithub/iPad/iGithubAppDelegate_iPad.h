//
//  iGithubAppDelegate_iPad.h
//  iGithub
//
//  Created by Oliver Letterer on 29.03.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iGithubAppDelegate.h"
#import "ANAdvancedNavigationController.h"

#warning make keychain submodule?

@interface iGithubAppDelegate_iPad : iGithubAppDelegate <ANAdvancedNavigationControllerDelegate> {
    ANAdvancedNavigationController *_advancedNavigationController;
}

@property (nonatomic, retain) ANAdvancedNavigationController *advancedNavigationController;


@end
