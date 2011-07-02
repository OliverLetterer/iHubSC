//
//  GHPUsersFromRepositoryViewController.h
//  iGithub
//
//  Created by Oliver Letterer on 02.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GHPUsersViewController.h"

@interface GHPUsersFromRepositoryViewController : GHPUsersViewController {
@private
    NSString *_repository;
}

@property (nonatomic, copy) NSString *repository;

- (id)initWithRepository:(NSString *)repository;

@end
