//
//  GHViewPullRequestViewController.h
//  iGithub
//
//  Created by Oliver Letterer on 14.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GHViewIssueTableViewController.h"

@interface GHViewPullRequestViewController : GHViewIssueTableViewController {
@private
    
}

- (void)moreButtonClicked:(UIBarButtonItem *)sender;

@end
