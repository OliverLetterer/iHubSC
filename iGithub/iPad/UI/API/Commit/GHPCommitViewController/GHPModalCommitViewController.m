//
//  GHPModalCommitViewController.m
//  iGithub
//
//  Created by Oliver Letterer on 08.11.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHPModalCommitViewController.h"
#import "GHPCommitViewController.h"



@implementation GHPModalCommitViewController

#pragma mark - setters and getters

#pragma mark - Initialization

- (id)initWithRepository:(NSString *)repository commitID:(NSString *)commitID
{
    GHPCommitViewController *viewController = [[GHPCommitViewController alloc] initWithRepository:repository commitID:commitID];
    if (self = [super initWithRootViewController:viewController]) {
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone 
                                                                              target:self
                                                                              action:@selector(doneBarButtonItemClicked:)];
        viewController.navigationItem.rightBarButtonItem = item;
    }
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad 
{
    [super viewDidLoad];
}

#pragma mark - target actions

- (void)doneBarButtonItemClicked:(UIBarButtonItem *)sender
{
    [self.presentingViewController dismissModalViewControllerAnimated:YES];
}

@end
