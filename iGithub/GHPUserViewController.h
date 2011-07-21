//
//  GHPUserViewController.h
//  iGithub
//
//  Created by Oliver Letterer on 01.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GHTableViewController.h"
#import <MessageUI/MessageUI.h>
#import "GHPInfoSectionTableViewController.h"

@interface GHPUserViewController : GHPInfoSectionTableViewController <MFMailComposeViewControllerDelegate, NSCoding> {
    GHAPIUserV3 *_user;
    NSString *_username;
    
    BOOL _hasFollowingData;
    BOOL _isFollowingUser;
}

@property (nonatomic, retain) GHAPIUserV3 *user;
@property (nonatomic, copy) NSString *username;

@property (nonatomic, readonly) NSString *userDetailInfoString;

@property (nonatomic, readonly) BOOL isAdminsitrativeUser;

- (id)initWithUsername:(NSString *)username;

@end
