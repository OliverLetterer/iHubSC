//
//  GHSingleRepositoryViewController.h
//  iGithub
//
//  Created by Oliver Letterer on 09.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GHTableViewController.h"

@interface GHSingleRepositoryViewController : GHTableViewController {
@private
    NSString *_repository;
}

@property (nonatomic, copy) NSString *repository;

- (id)initWithRepository:(NSString *)repository;

@end
