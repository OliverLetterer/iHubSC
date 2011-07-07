//
//  GHPRepositoriesViewController.h
//  iGithub
//
//  Created by Oliver Letterer on 01.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GHPDataArrayViewController.h"

@interface GHPRepositoriesViewController : GHPDataArrayViewController {
@private
    NSString *_username;
}

@property (nonatomic, copy) NSString *username;

- (id)initWithUsername:(NSString *)username;

@end
