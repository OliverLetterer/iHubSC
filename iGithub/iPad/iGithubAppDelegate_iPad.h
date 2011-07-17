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

#warning API V3 returns timestamp that does not work with local time

@interface iGithubAppDelegate_iPad : iGithubAppDelegate <ANAdvancedNavigationControllerDelegate> {
    
}

@end
