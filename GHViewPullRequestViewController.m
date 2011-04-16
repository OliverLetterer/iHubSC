//
//  GHViewPullRequestViewController.m
//  iGithub
//
//  Created by Oliver Letterer on 14.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHViewPullRequestViewController.h"


@implementation GHViewPullRequestViewController

#pragma mark - Initialization

- (id)initWithRepository:(NSString *)repository issueNumber:(NSNumber *)number {
    if ((self = [super initWithRepository:repository issueNumber:number])) {
        self.title = [NSString stringWithFormat:NSLocalizedString(@"Pull Request %@", @""), self.number];
    }
    return self;
}

#pragma mark - Memory management

- (void)dealloc {
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - target actions

- (void)moreButtonClicked:(UIBarButtonItem *)sender {
//    UIActionSheet *sheet = [[[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Show", @"") 
//                                                        delegate:self 
//                                               cancelButtonTitle:NSLocalizedString(@"Cancel", @"") 
//                                          destructiveButtonTitle:nil 
//                                               otherButtonTitles:NSLocalizedString(@"Commits", @""), NSLocalizedString(@"Diff", @""), nil]
//                            autorelease];
//    sheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
//    [sheet showInView:self.tabBarController.view];
}

#pragma mark - View lifecycle

/*
 - (void)loadView {
 
 }
 */

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    UIBarButtonItem *item = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction 
//                                                                           target:self 
//                                                                           action:@selector(moreButtonClicked:)]
//                             autorelease];
//    self.navigationItem.rightBarButtonItem = item;
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
