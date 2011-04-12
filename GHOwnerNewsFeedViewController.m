//
//  GHOwnerNewsFeedViewController.m
//  iGithub
//
//  Created by Oliver Letterer on 12.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHOwnerNewsFeedViewController.h"
#import "GithubAPI.h"
#import "GHSettingsHelper.h"
#import "GHFeedItemWithDescriptionTableViewCell.h"
#import "GHPushFeedItemTableViewCell.h"
#import "GHFollowEventTableViewCell.h"
#import "GHViewIssueTableViewController.h"

@implementation GHOwnerNewsFeedViewController

@synthesize segmentControl=_segmentControl;

#pragma mark - Initialization

- (id)init {
    if ((self = [super init])) {
        self.title = NSLocalizedString(@"News", @"");
        
        self.tabBarItem = [[[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"News", @"") 
                                                         image:[UIImage imageNamed:@"56-feed.png"] 
                                                           tag:0]
                           autorelease];
        
        self.reloadDataIfNewUserGotAuthenticated = YES;
    }
    return self;
}

#pragma mark - Memory management

- (void)dealloc {
    [_segmentControl release];
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
    
    self.segmentControl = [[[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:
                                                                      NSLocalizedString(@"News Feed", @""), 
                                                                      NSLocalizedString(@"My Actions", @""), 
                                                                      nil]] 
                           autorelease];
    self.segmentControl.segmentedControlStyle = UISegmentedControlStyleBar;
    self.segmentControl.selectedSegmentIndex = 0;
    self.navigationItem.titleView = self.segmentControl;
    self.segmentControl.userInteractionEnabled = NO;
    self.segmentControl.alpha = 0.5;
    [self.segmentControl addTarget:self action:@selector(segmentControlValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    if ([GHSettingsHelper isUserAuthenticated]) {
        [GHNewsFeed privateNewsWithCompletionHandler:^(GHNewsFeed *feed, NSError *error) {
            if (error) {
                [self handleError:error];
            } else {
                self.newsFeed = feed;
                self.segmentControl.userInteractionEnabled = YES;
                self.segmentControl.alpha = 1.0;
            }
            [self didReloadData];
        }];
    }
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    [_segmentControl release];
    _segmentControl = nil;
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

- (void)reloadData {
    [self loadDataBasedOnSegmentControl];
}

- (void)loadDataBasedOnSegmentControl {
    if (self.segmentControl.selectedSegmentIndex == 0) {
        // News Feed
        [GHNewsFeed privateNewsWithCompletionHandler:^(GHNewsFeed *feed, NSError *error) {
            if (error) {
                [self handleError:error];
            } else {
                self.newsFeed = feed;
                self.segmentControl.userInteractionEnabled = YES;
                self.segmentControl.alpha = 1.0;
            }
            [self didReloadData];
        }];
    } else if (self.segmentControl.selectedSegmentIndex == 1) {
        // My Actions
        [GHNewsFeed newsFeedForUserNamed:[GHSettingsHelper username] 
                       completionHandler:^(GHNewsFeed *feed, NSError *error) {
                           if (error) {
                               [self handleError:error];
                           } else {
                               self.newsFeed = feed;
                               self.segmentControl.userInteractionEnabled = YES;
                               self.segmentControl.alpha = 1.0;
                           }
                           [self didReloadData];
                       }];
    }
}

#pragma mark - target actions

- (void)segmentControlValueChanged:(UISegmentedControl *)segmentControl {
    self.newsFeed = nil;
    self.segmentControl.userInteractionEnabled = NO;
    self.segmentControl.alpha = 0.5;
    
    [self loadDataBasedOnSegmentControl];
}

@end
