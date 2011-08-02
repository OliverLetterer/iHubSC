//
//  ANNotificationQueueRootViewController.m
//  iGithub
//
//  Created by Oliver Letterer on 02.08.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "ANNotificationQueueRootViewController.h"

@implementation ANNotificationQueueRootViewController

#pragma mark - View lifecycle

- (void)loadView {
    [super loadView];
    self.view.backgroundColor = [UIColor clearColor];
    _backgroundView = [[ANNotificationQueueRootViewControllerView alloc] initWithFrame:self.view.bounds];
    _backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_backgroundView];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    _backgroundView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
	return YES;
}

@end
