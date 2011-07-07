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

#warning User->Organizations missing
#warning NewsFeeds are missing

#warning Repository->Pull Requests are missing
#warning Repository->BrowseContent is missing

- (void)deviceOrientationDidChangeNotificationCallback:(NSNotification *)notification;

@end
