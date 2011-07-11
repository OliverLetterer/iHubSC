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

#warning authentication not working
#warning User->Organizations missing

- (void)deviceOrientationDidChangeNotificationCallback:(NSNotification *)notification;

@end
