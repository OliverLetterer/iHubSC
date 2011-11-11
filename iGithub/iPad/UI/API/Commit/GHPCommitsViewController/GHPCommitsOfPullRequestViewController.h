//
//  GHPCommitsOfPullRequestViewController.h
//  iGithub
//
//  Created by Oliver Letterer on 11.11.11.
//  Copyright (c) 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GHPCommitsViewController.h"



@interface GHPCommitsOfPullRequestViewController : GHPCommitsViewController {
    NSNumber *_issueNumber;
}

- (id)initWithRepositoryString:(NSString *)repositoryString issueNumber:(NSNumber *)issueNumber;

@end
