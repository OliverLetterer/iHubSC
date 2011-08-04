//
//  GHPUserViewController.h
//  iGithub
//
//  Created by Oliver Letterer on 01.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "GHTableViewController.h"
#import "GHPInfoSectionTableViewController.h"
#import "GHCreateRepositoryViewController.h"

@interface GHPUserViewController : GHPInfoSectionTableViewController <MFMailComposeViewControllerDelegate, NSCoding, GHCreateRepositoryViewControllerDelegate> {
    GHAPIUserV3 *_user;
    NSString *_username;
    
    BOOL _hasFollowingData;
    BOOL _isFollowingUser;
}

@property (nonatomic, retain) GHAPIUserV3 *user;
@property (nonatomic, copy) NSString *username;

@property (nonatomic, readonly) NSString *userDetailInfoString;

@property (nonatomic, readonly) BOOL isAdminsitrativeUser;

@property (nonatomic, readonly) BOOL canFollowUser;


- (id)initWithUsername:(NSString *)username;

@end
