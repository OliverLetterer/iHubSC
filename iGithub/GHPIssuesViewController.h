//
//  GHPIssuesViewController.h
//  iGithub
//
//  Created by Oliver Letterer on 04.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GHTableViewController.h"

@interface GHPIssuesViewController : GHTableViewController {
@private
    NSMutableArray *_issues;
}

@property (nonatomic, retain) NSMutableArray *issues;

- (void)cacheIssuesHeight;

@end
