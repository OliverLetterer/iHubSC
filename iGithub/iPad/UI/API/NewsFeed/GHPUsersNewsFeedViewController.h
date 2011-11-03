//
//  GHPUsersNewsFeedViewController.h
//  iGithub
//
//  Created by Oliver Letterer on 11.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GHPNewsFeedViewController.h"



@interface GHPUsersNewsFeedViewController : GHPNewsFeedViewController <NSCoding> {
@private
    NSString *_username;
}

@property (nonatomic, copy) NSString *username;

- (id)initWithUsername:(NSString *)username;

@end
