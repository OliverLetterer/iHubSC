//
//  iGithubAppDelegate_iPad.h
//  iGithub
//
//  Created by Oliver Letterer on 29.03.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iGithubAppDelegate.h"

@interface iGithubAppDelegate_iPad : iGithubAppDelegate {
    
}

#warning adopt GHPInfoSectionTableViewController
#warning new TweetBot like Notifications
#warning adopt avatarURL instead of gravatarID

- (void)deviceOrientationDidChangeNotificationCallback:(NSNotification *)notification;

@end
