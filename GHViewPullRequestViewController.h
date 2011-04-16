//
//  GHViewPullRequestViewController.h
//  iGithub
//
//  Created by Oliver Letterer on 14.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GHTableViewController.h"
#import "GithubAPI.h"

@interface GHViewPullRequestViewController : GHTableViewController {
@private
    NSString *_repository;
    NSNumber *_number;
    GHPullRequestDiscussion *_discussion;
    
    UITextView *_textView;
    UIToolbar *_textViewToolBar;
}

@property (nonatomic, copy) NSString *repository;
@property (nonatomic, copy) NSNumber *number;
@property (nonatomic, retain) GHPullRequestDiscussion *discussion;

@property (nonatomic, retain) UITextView *textView;
@property (nonatomic, retain) UIToolbar *textViewToolBar;

- (id)initWithRepository:(NSString *)repository issueNumber:(NSNumber *)number;

- (void)downloadDiscussionData;

@end
