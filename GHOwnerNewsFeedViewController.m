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
#import "MTStatusBarOverlay.h"

#define GHOwnerNewsFeedViewControllerDefaultOrganizationNameKey @"GHOwnerNewsFeedViewControllerDefaultOrganizationName"
#define GHOwnerNewsFeedViewControllerLastCreationDateKey @"GHOwnerNewsFeedViewControllerLastCreationDate"

@implementation GHOwnerNewsFeedViewController

@synthesize segmentControl=_segmentControl, organizations=_organizations, defaultOrganizationName=_defaultOrganizationName, lastCreationDate=_lastCreationDate;

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

- (void)setLastCreationDate:(NSString *)lastCreationDate {
    [_lastCreationDate release];
    _lastCreationDate = [lastCreationDate copy];
    
    [[NSUserDefaults standardUserDefaults] setObject:_lastCreationDate forKey:GHOwnerNewsFeedViewControllerLastCreationDateKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)lastCreationDate {
    if (!_lastCreationDate) {
        _lastCreationDate = [[[NSUserDefaults standardUserDefaults] objectForKey:GHOwnerNewsFeedViewControllerLastCreationDateKey] copy];
    }
    
    return _lastCreationDate;
}

- (void)setNewsFeed:(GHNewsFeed *)newsFeed {
    [super setNewsFeed:newsFeed];
    
    if (newsFeed) {
        
        NSUInteger index = [_newsFeed.items indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
            GHNewsFeedItem *item = obj;
            if ([item.creationDate isEqualToString:self.lastCreationDate]) {
                *stop = YES;
                return YES;
            }
            return NO;
        }];
        
        if (index != NSNotFound && index > 0) {
            CGRect rect = [self.tableView rectForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] ];
            CGPoint scrollPoint = CGPointMake(0.0, rect.origin.y - 61.0f);
            [self.tableView setContentOffset:scrollPoint animated:NO];
        }
        
        if (newsFeed.items.count > 0) {
            GHNewsFeedItem *item = [newsFeed.items objectAtIndex:0];
            self.lastCreationDate = item.creationDate;
        }
        
        if (index == NSNotFound) {
            index = 0;
        }
        [self didRefreshNewsFeed:[NSString stringWithFormat:NSLocalizedString(@"%d new Messages", @""), index] ];
    }
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
    [_lastCreationDate release];
    
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

- (void)pullToReleaseTableViewReloadData {
    [super pullToReleaseTableViewReloadData];
    [self loadDataBasedOnSegmentControl];
}

- (void)showLoadingInformation:(NSString *)infoString {
    [[MTStatusBarOverlay sharedOverlay] postMessage:infoString];
}

- (void)didRefreshNewsFeed:(NSString *)infoString {
    [[MTStatusBarOverlay sharedOverlay] postFinishMessage:infoString duration:1.0f animated:YES];
}

- (void)loadDataBasedOnSegmentControl {
    if (self.segmentControl.selectedSegmentIndex == 0) {
        // News Feed
        [self showLoadingInformation:NSLocalizedString(@"Fetching private News Feed", @"")];
        [GHNewsFeed privateNewsWithCompletionHandler:^(GHNewsFeed *feed, NSError *error) {
            if (error) {
                [self handleError:error];
            } else {
                self.newsFeed = feed;
                self.segmentControl.userInteractionEnabled = YES;
                self.segmentControl.alpha = 1.0;
            }
            [self pullToReleaseTableViewDidReloadData];
        }];
    } else if (self.segmentControl.selectedSegmentIndex == 1) {
        // My Actions
        [self showLoadingInformation:NSLocalizedString(@"Fetching My Actions", @"")];
        [GHNewsFeed newsFeedForUserNamed:[GHSettingsHelper username] 
                       completionHandler:^(GHNewsFeed *feed, NSError *error) {
                           if (error) {
                               [self handleError:error];
                           } else {
                               self.newsFeed = feed;
                               self.segmentControl.userInteractionEnabled = YES;
                               self.segmentControl.alpha = 1.0;
                           }
                           [self pullToReleaseTableViewDidReloadData];
                       }];
    } else if (self.segmentControl.selectedSegmentIndex == 2) {
        if (self.defaultOrganizationName) {
            [self showLoadingInformation:[NSString stringWithFormat:NSLocalizedString(@"Fetching %@ News Feed", @""), self.defaultOrganizationName] ];
            [GHNewsFeed newsFeedForUserNamed:self.defaultOrganizationName completionHandler:^(GHNewsFeed *feed, NSError *error) {
                if (error) {
                    [self handleError:error];
                } else {
                    self.newsFeed = feed;
                    self.segmentControl.userInteractionEnabled = YES;
                    self.segmentControl.alpha = 1.0;
                }
                [self pullToReleaseTableViewDidReloadData];
            }];
        } else {
            [self showLoadingInformation:NSLocalizedString(@"Fetching Organizations", @"")];
            [GHAPIOrganizationV3 organizationsOfUser:[GHAuthenticationManager sharedInstance].username 
                                                page:1 
                                   completionHandler:^(NSMutableArray *array, NSUInteger nextPage, NSError *error) {
                                       self.organizations = array;
                                       
                                       if (self.organizations.count > 0) {
                                           if (self.organizations.count == 1) {
                                               // we only have one organization, act as if user select this only organization
                                               [self displayOrganizationAtIndex:0];
                                           } else {
                                               UIActionSheet *sheet = [[[UIActionSheet alloc] init] autorelease];
                                               
                                               [sheet setTitle:NSLocalizedString(@"Select an Organization", @"")];
                                               
                                               for (GHAPIOrganizationV3 *organization in self.organizations) {
                                                   [sheet addButtonWithTitle:organization.login];
                                               }
                                               
                                               [sheet addButtonWithTitle:NSLocalizedString(@"Cancel", @"")];
                                               sheet.cancelButtonIndex = sheet.numberOfButtons-1;
                                               
                                               sheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
                                               
                                               sheet.delegate = self;
                                               
                                               [sheet showInView:self.tabBarController.view];
                                           }
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

- (void)displayOrganizationAtIndex:(NSUInteger)index {
    GHAPIOrganizationV3 *organization = [self.organizations objectAtIndex:index];
    
    self.defaultOrganizationName = organization.login;
    
    [self showLoadingInformation:[NSString stringWithFormat:NSLocalizedString(@"Download %@ News Feed", @""), self.defaultOrganizationName] ];
    
    [GHNewsFeed newsFeedForUserNamed:self.defaultOrganizationName completionHandler:^(GHNewsFeed *feed, NSError *error) {
        if (error) {
            [self handleError:error];
        } else {
            self.newsFeed = feed;
            self.segmentControl.userInteractionEnabled = YES;
            self.segmentControl.alpha = 1.0;
        }
        [self pullToReleaseTableViewDidReloadData];
    }];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex < actionSheet.numberOfButtons - 1) {
        [self displayOrganizationAtIndex:buttonIndex];
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
    
    [self pullToReleaseTableViewReloadData];
}

@end
