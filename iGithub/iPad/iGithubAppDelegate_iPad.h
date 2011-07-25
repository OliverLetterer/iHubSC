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

#warning Writing comments. Infinite number of action sheets
#warning Navigate forward while typing a comment causes strange things to happen

@interface iGithubAppDelegate_iPad : iGithubAppDelegate <ANAdvancedNavigationControllerDelegate> {
    ANAdvancedNavigationController *_advancedNavigationController;
}

@property (nonatomic, retain) ANAdvancedNavigationController *advancedNavigationController;


@end
