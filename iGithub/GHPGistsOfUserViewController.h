//
//  GHPGistsOfUserViewController.h
//  iGithub
//
//  Created by Oliver Letterer on 07.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GHPGistsViewController.h"

@interface GHPGistsOfUserViewController : GHPGistsViewController {
@private
    NSString *_username;
}

@property (nonatomic, copy) NSString *username;

- (id)initWithUsername:(NSString *)username;

@end
