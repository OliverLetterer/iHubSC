//
//  GHPUserViewController.h
//  iGithub
//
//  Created by Oliver Letterer on 01.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GHPTableViewController.h"

@interface GHPUserViewController : GHPTableViewController {
    GHAPIUserV3 *_user;
    NSString *_username;
}

@property (nonatomic, retain) GHAPIUserV3 *user;
@property (nonatomic, copy) NSString *username;

@property (nonatomic, readonly) NSString *userDetailInfoString;

- (id)initWithUsername:(NSString *)username;

@end
