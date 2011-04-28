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

#define GHOwnerNewsFeedViewControllerDefaultOrganizationNameKey @"GHOwnerNewsFeedViewControllerDefaultOrganizationName"

@implementation GHOwnerNewsFeedViewController

@synthesize segmentControl=_segmentControl, organizations=_organizations, defaultOrganizationName=_defaultOrganizationName;

- (void)setDefaultOrganizationName:(NSString *)defaultOrganizationName {
    [_defaultOrganizationName release];
    _defaultOrganizationName = [defaultOrganizationName copy];
    
    [[NSUserDefaults standardUserDefaults] setObject:_defaultOrganizationName forKey:GHOwnerNewsFeedViewControllerDefaultOrganizationNameKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)defaultOrganizationName {
    if (!_defaultOrganizationName) {
        _defaultOrganizationName = [[[NSUserDefaults standardUserDefaults] objectForKey:GHOwnerNewsFeedViewControllerDefaultOrganizationNameKey] copy];
    }
    
    return _defaultOrganizationName;
}

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
    [_organizations release];
    [_defaultOrganizationName release];
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)loadView {
    [super loadView];
    
    self.segmentControl = [[[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:
                                                                      NSLocalizedString(@"News Feed", @""), 
                                                                      NSLocalizedString(@"My Actions", @""), 
                                                                      NSLocalizedString(@"Organizations", @""),
                                                                      nil]] 
                           autorelease];
    self.segmentControl.segmentedControlStyle = UISegmentedControlStyleBar;
    self.navigationItem.titleView = self.segmentControl;
    self.segmentControl.userInteractionEnabled = NO;
    self.segmentControl.alpha = 0.5;
    if (self.defaultOrganizationName) {
        self.segmentControl.selectedSegmentIndex = 2;
    } else {
        self.segmentControl.selectedSegmentIndex = 0;
    }
    [self.segmentControl addTarget:self action:@selector(segmentControlValueChanged:) forControlEvents:UIControlEventValueChanged];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadDataBasedOnSegmentControl];
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

- (void)authenticationViewControllerdidAuthenticateUserCallback:(NSNotification *)notification {
    self.segmentControl.selectedSegmentIndex = 0;
    [super authenticationViewControllerdidAuthenticateUserCallback:notification];
}

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
    } else if (self.segmentControl.selectedSegmentIndex == 2) {
        if (self.defaultOrganizationName) {
            [GHNewsFeed newsFeedForUserNamed:self.defaultOrganizationName completionHandler:^(GHNewsFeed *feed, NSError *error) {
                if (error) {
                    [self handleError:error];
                } else {
                    self.newsFeed = feed;
                    self.segmentControl.userInteractionEnabled = YES;
                    self.segmentControl.alpha = 1.0;
                }
                [self didReloadData];
            }];
        } else {
            [GHOrganization organizationsOfUser:[GHSettingsHelper username] 
                              completionHandler:^(NSArray *organizations, NSError *error) {
                                  
                                  self.organizations = organizations;
                                  
                                  if (self.organizations.count > 0) {
                                      UIActionSheet *sheet = [[[UIActionSheet alloc] init] autorelease];
                                      
                                      [sheet setTitle:NSLocalizedString(@"Select an Organization", @"")];
                                      
                                      for (GHOrganization *organization in organizations) {
                                          [sheet addButtonWithTitle:organization.login];
                                      }
                                      
                                      [sheet addButtonWithTitle:NSLocalizedString(@"Cancel", @"")];
                                      sheet.cancelButtonIndex = sheet.numberOfButtons-1;
                                      
                                      sheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
                                      
                                      sheet.delegate = self;
                                      
                                      [sheet showInView:self.tabBarController.view];
                                      
                                  } else {
                                      self.segmentControl.selectedSegmentIndex = 0;
                                      UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Organization Error", @"") 
                                                                                       message:NSLocalizedString(@"You are not part of any Organization!", @"") 
                                                                                      delegate:nil 
                                                                             cancelButtonTitle:NSLocalizedString(@"OK", @"") 
                                                                             otherButtonTitles:nil]
                                                            autorelease];
                                      [alert show];
                                  }
                              }];
        }
    }
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex < actionSheet.numberOfButtons - 1) {
        GHOrganization *organization = [self.organizations objectAtIndex:buttonIndex];
        
        self.defaultOrganizationName = organization.login;
        
        [GHNewsFeed newsFeedForUserNamed:self.defaultOrganizationName completionHandler:^(GHNewsFeed *feed, NSError *error) {
            if (error) {
                [self handleError:error];
            } else {
                self.newsFeed = feed;
                self.segmentControl.userInteractionEnabled = YES;
                self.segmentControl.alpha = 1.0;
            }
            [self didReloadData];
        }];
    } else {
        [self.segmentControl setSelectedSegmentIndex:0];
    }
}

#pragma mark - target actions

- (void)segmentControlValueChanged:(UISegmentedControl *)segmentControl {
    self.newsFeed = nil;
    self.segmentControl.userInteractionEnabled = NO;
    self.segmentControl.alpha = 0.5;
    self.defaultOrganizationName = nil;
    
    [self loadDataBasedOnSegmentControl];
}

@end
