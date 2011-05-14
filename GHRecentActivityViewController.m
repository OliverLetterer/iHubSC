//
//  GHRecentActivityViewController.m
//  iGithub
//
//  Created by Oliver Letterer on 12.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHRecentActivityViewController.h"
#import "GithubAPI.h"

@implementation GHRecentActivityViewController

@synthesize username=_username;

#pragma mark - setters and getters

- (void)setUsername:(NSString *)username {
    [_username release];
    _username = [username copy];
    [self pullToReleaseTableViewReloadData];
}

#pragma mark - Initialization

- (id)initWithUsername:(NSString *)username {
    if ((self = [self init])) {
        self.username = username;
    }
    return self;
}

- (id)init {
    if ((self = [super init])) {
        self.title = NSLocalizedString(@"Recent activity", @"");
    }
    return self;
}

#pragma mark - Memory management

- (void)dealloc {
    [_username release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
 - (void)loadView {
 
 }
 */

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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

#pragma mark - instance methods

- (void)pullToReleaseTableViewReloadData {
    [super pullToReleaseTableViewReloadData];
    [GHNewsFeed newsFeedForUserNamed:self.username completionHandler:^(GHNewsFeed *feed, NSError *error) {
        if (error) {
            [self handleError:error];
        } else {
            self.newsFeed = feed;
        }
        [self pullToReleaseTableViewDidReloadData];
    }];
}

@end
