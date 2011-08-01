//
//  GHRecentActivityViewController.h
//  iGithub
//
//  Created by Oliver Letterer on 12.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GHNewsFeedViewController.h"

@interface GHRecentActivityViewController : GHNewsFeedViewController {
@private
    NSString *_username;
}

@property (nonatomic, copy) NSString *username;

- (id)initWithUsername:(NSString *)username;

@end
