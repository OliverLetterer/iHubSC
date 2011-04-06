//
//  GHRepositoriesViewController.h
//  iGithub
//
//  Created by Oliver Letterer on 06.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GHTableViewController.h"

@interface GHRepositoriesViewController : GHTableViewController {
@private
    NSArray *_repositoriesArray;
}

@property (nonatomic, retain) NSArray *repositoriesArray;

@end
