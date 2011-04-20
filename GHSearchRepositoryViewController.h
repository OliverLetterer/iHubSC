//
//  GHSearchRepositoryViewController.h
//  iGithub
//
//  Created by Oliver Letterer on 20.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GHTableViewController.h"

@interface GHSearchRepositoryViewController : GHTableViewController {
@private
    NSString *_searchString;
    NSArray *_repositories;
}

@property (nonatomic, copy) NSString *searchString;
@property (nonatomic, retain) NSArray *repositories;

- (id)initWithSearchString:(NSString *)searchString;
- (void)cacheHeightForRepositories;

@end
