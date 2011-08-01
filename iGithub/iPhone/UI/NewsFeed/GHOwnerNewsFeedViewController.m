//
//  GHOwnerNewsFeedViewController.m
//  iGithub
//
//  Created by Oliver Letterer on 12.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHOwnerNewsFeedViewController.h"
#import "GHOwnerNewsFeedViewController+Private.h"
#import "GithubAPI.h"
#import "GHDescriptionTableViewCell.h"
#import "GHFollowEventTableViewCell.h"
#import "GHIssueViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "UIColor+GithubUI.h"

#import "GHUserViewController.h"
#import "GHRepositoryViewController.h"

#define GHOwnerNewsFeedViewControllerDefaultOrganizationNameKey @"GHOwnerNewsFeedViewControllerDefaultOrganizationName"
#define GHOwnerNewsFeedViewControllerLastCreationDateKey @"GHOwnerNewsFeedViewControllerLastCreationDate"

@implementation GHOwnerNewsFeedViewController

@synthesize segmentControl=_segmentControl, stateSegmentControl=_stateSegmentControl;
@synthesize organizations=_organizations, defaultOrganizationName=_defaultOrganizationName, lastCreationDate=_lastCreationDate;
@synthesize pendingStateStringsArray=_pendingStateStringsArray, lastStateUpdateDate=_lastStateUpdateDate;

- (void)setDefaultOrganizationName:(NSString *)defaultOrganizationName {
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

- (void)setNewsFeed:(GHNewsFeed *)newsFeed updateScrollView:(BOOL)updateScrollView {
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
        
        if (updateScrollView) {
            if (index != NSNotFound && index > 0) {
                CGRect rect = [self.tableView rectForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] ];
                CGPoint scrollPoint = CGPointMake(0.0, rect.origin.y - 61.0f);
                [self.tableView setContentOffset:scrollPoint animated:NO];
            }
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
        
        self.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"News", @"") 
                                                         image:[UIImage imageNamed:@"56-feed.png"] 
                                                           tag:0];
        
        self.reloadDataIfNewUserGotAuthenticated = YES;
        self.pendingStateStringsArray = [NSMutableArray array];
    }
    return self;
}

#pragma mark - Memory management


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)loadView {
    [super loadView];
    
    UIView *wrapperView = [[UIView alloc] initWithFrame:CGRectMake(17.0f, 6.0f, 286.0f, 32.0f)];
    self.segmentControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:
                                                                      NSLocalizedString(@"News Feed", @""), 
                                                                      NSLocalizedString(@"My Actions", @""), 
                                                                      NSLocalizedString(@"Organizations", @""),
                                                                      nil]];
    self.segmentControl.segmentedControlStyle = UISegmentedControlStyleBar;
    [wrapperView addSubview:self.segmentControl];
    self.navigationItem.titleView = wrapperView;
    self.segmentControl.userInteractionEnabled = YES;
    self.segmentControl.alpha = 1.0f;
    self.segmentControl.tintColor = [UIColor defaultNavigationBarTintColor];
    if (self.defaultOrganizationName) {
        self.segmentControl.selectedSegmentIndex = 2;
    } else {
        self.segmentControl.selectedSegmentIndex = 0;
    }
    self.segmentControl.selectedSegmentIndex = _lastSelectedSegmentControlIndex;
    [self.segmentControl addTarget:self action:@selector(segmentControlValueChanged:) forControlEvents:UIControlEventValueChanged];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (!self.newsFeed) {
        [self pullToReleaseTableViewReloadData];
    }
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    _segmentControl = nil;
}

#pragma mark - instance methods

- (void)authenticationManagerDidAuthenticateUserCallback:(NSNotification *)notification {
    self.segmentControl.selectedSegmentIndex = 0;
    [super authenticationManagerDidAuthenticateUserCallback:notification];
}

- (void)pullToReleaseTableViewReloadData {
    [super pullToReleaseTableViewReloadData];
    [self loadDataBasedOnSegmentControl];
}

- (void)showLoadingInformation:(NSString *)infoString {
    [self detachNewStateString:infoString removeAfterDisplayed:NO];
}

#define kFinishedText		@"‚úî"

- (void)didRefreshNewsFeed:(NSString *)infoString {
    [self detachNewStateString:[NSString stringWithFormat:@"%C \t %@", 10004, infoString] removeAfterDisplayed:YES];
}

- (void)loadDataBasedOnSegmentControl {
    // disable the segment control
    self.segmentControl.userInteractionEnabled = NO;
    self.segmentControl.alpha = 0.5;
    
    if (!self.newsFeed) {
        self.isDownloadingEssentialData = YES;
    }
    if (self.segmentControl) {
        _lastSelectedSegmentControlIndex = self.segmentControl.selectedSegmentIndex;
    }
    _updateScrollView = self.segmentControl != nil;
    
    // download new data
    if (_lastSelectedSegmentControlIndex == 0) {
        // News Feed
        self.defaultOrganizationName = nil;
        [self showLoadingInformation:NSLocalizedString(@"Fetching private News Feed", @"")];
        [GHNewsFeed privateNewsWithCompletionHandler:^(GHNewsFeed *feed, NSError *error) {
            self.isDownloadingEssentialData = NO;
            if (error) {
                [self detachNewStateString:NSLocalizedString(@"Error", @"") removeAfterDisplayed:YES];
                self.segmentControl.userInteractionEnabled = YES;
                self.segmentControl.alpha = 1.0;
                [self handleError:error];
            } else {
                [self setNewsFeed:feed updateScrollView:_updateScrollView];
                self.segmentControl.userInteractionEnabled = YES;
                self.segmentControl.alpha = 1.0;
            }
            [self pullToReleaseTableViewDidReloadData];
        }];
    } else if (_lastSelectedSegmentControlIndex == 1) {
        // My Actions
        [self showLoadingInformation:NSLocalizedString(@"Fetching My Actions", @"")];
        [GHNewsFeed newsFeedForUserNamed:[GHAPIAuthenticationManager sharedInstance].authenticatedUser.login 
                       completionHandler:^(GHNewsFeed *feed, NSError *error) {
                           self.isDownloadingEssentialData = NO;
                           if (error) {
                               [self detachNewStateString:NSLocalizedString(@"Error", @"") removeAfterDisplayed:YES];
                               self.segmentControl.userInteractionEnabled = YES;
                               self.segmentControl.alpha = 1.0;
                               [self handleError:error];
                           } else {
                               [self setNewsFeed:feed updateScrollView:_updateScrollView];
                               self.segmentControl.userInteractionEnabled = YES;
                               self.segmentControl.alpha = 1.0;
                           }
                           [self pullToReleaseTableViewDidReloadData];
                       }];
    } else if (_lastSelectedSegmentControlIndex == 2) {
        if (self.defaultOrganizationName) {
            [self showLoadingInformation:[NSString stringWithFormat:NSLocalizedString(@"Fetching %@ News Feed", @""), self.defaultOrganizationName] ];
            [GHNewsFeed newsFeedForUserNamed:self.defaultOrganizationName completionHandler:^(GHNewsFeed *feed, NSError *error) {
                self.isDownloadingEssentialData = NO;
                if (error) {
                    [self detachNewStateString:NSLocalizedString(@"Error", @"") removeAfterDisplayed:YES];
                    self.segmentControl.userInteractionEnabled = YES;
                    self.segmentControl.alpha = 1.0;
                    [self handleError:error];
                } else {
                    [self setNewsFeed:feed updateScrollView:_updateScrollView];
                    self.segmentControl.userInteractionEnabled = YES;
                    self.segmentControl.alpha = 1.0;
                }
                [self pullToReleaseTableViewDidReloadData];
            }];
        } else {
            [self showLoadingInformation:NSLocalizedString(@"Fetching Organizations", @"")];
            [GHAPIOrganizationV3 organizationsOfUser:[GHAPIAuthenticationManager sharedInstance].authenticatedUser.login 
                                                page:1 
                                   completionHandler:^(NSMutableArray *array, NSUInteger nextPage, NSError *error) {
                                       self.isDownloadingEssentialData = NO;
                                       self.organizations = array;
                                       
                                       if (self.organizations.count > 0) {
                                           if (self.organizations.count == 1) {
                                               // we only have one organization, act as if user select this only organization
                                               [self displayOrganizationAtIndex:0];
                                           } else {
                                               UIActionSheet *sheet = [[UIActionSheet alloc] init];
                                               
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
                                           _lastSelectedSegmentControlIndex = 0;
                                           [self loadDataBasedOnSegmentControl];
                                           UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Organization Error", @"") 
                                                                                            message:NSLocalizedString(@"You are not part of any Organization!", @"") 
                                                                                           delegate:nil 
                                                                                  cancelButtonTitle:NSLocalizedString(@"OK", @"") 
                                                                                  otherButtonTitles:nil];
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
            [self detachNewStateString:NSLocalizedString(@"Error", @"") removeAfterDisplayed:YES];
            self.segmentControl.userInteractionEnabled = YES;
            self.segmentControl.alpha = 1.0;
            [self handleError:error];
        } else {
            [self setNewsFeed:feed updateScrollView:_updateScrollView];
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
    [self pullToReleaseTableViewReloadData];
    self.newsFeed = nil;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    GHNewsFeedItem *item = [self.newsFeed.items objectAtIndex:indexPath.row];
    
    UIViewController *viewController = nil;
    
    if (item.payload.type == GHPayloadWatchEvent) {
        if ([item.repository.fullName hasPrefix:[GHAPIAuthenticationManager sharedInstance].authenticatedUser.login]) {
            // watched my repo, show the user
            viewController = [[GHUserViewController alloc] initWithUsername:item.actorAttributes.login];
        } else {
            // show me the repo that he is following
            viewController = [[GHRepositoryViewController alloc] initWithRepositoryString:item.repository.fullName];
        }
    } else if (item.payload.type == GHPayloadFollowEvent) {
        GHFollowEventPayload *payload = (GHFollowEventPayload *)item.payload;
        if ([payload.target.login isEqualToString:[GHAPIAuthenticationManager sharedInstance].authenticatedUser.login]) {
            // started following me, show me the user
            viewController = [[GHUserViewController alloc] initWithUsername:item.actorAttributes.login];
        } else {
            // following someone else, show me the target
            viewController = [[GHUserViewController alloc] initWithUsername:payload.target.login];
        }
    } else if (item.payload.type == GHPayloadForkEvent) {
        if ([item.repository.fullName hasPrefix:[GHAPIAuthenticationManager sharedInstance].authenticatedUser.login]) {
            // forked my repository, show me the user
            viewController = [[GHUserViewController alloc] initWithUsername:item.actorAttributes.login];
        } else {
            // didn't fork my repo, show me the repo
            viewController = [[GHRepositoryViewController alloc] initWithRepositoryString:item.repository.fullName];
        }
    }
    
    if (viewController) {
        [self.navigationController pushViewController:viewController animated:YES];
    } else {
        [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    }
}

#pragma mark - Keyed Archiving

- (void)encodeWithCoder:(NSCoder *)encoder {
    [super encodeWithCoder:encoder];
    [encoder encodeObject:_organizations forKey:@"organizations"];
    [encoder encodeObject:_defaultOrganizationName forKey:@"defaultOrganizationName"];
    [encoder encodeObject:_lastCreationDate forKey:@"lastCreationDate"];
    [encoder encodeObject:_pendingStateStringsArray forKey:@"pendingStateStringsArray"];
    [encoder encodeObject:_lastStateUpdateDate forKey:@"lastStateUpdateDate"];
    [encoder encodeInteger:_lastSelectedSegmentControlIndex forKey:@"lastSelectedSegmentControlIndex"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super initWithCoder:decoder])) {
        _organizations = [decoder decodeObjectForKey:@"organizations"];
        _defaultOrganizationName = [decoder decodeObjectForKey:@"defaultOrganizationName"];
        _lastCreationDate = [decoder decodeObjectForKey:@"lastCreationDate"];
        _pendingStateStringsArray = [decoder decodeObjectForKey:@"pendingStateStringsArray"];
        _lastStateUpdateDate = [decoder decodeObjectForKey:@"lastStateUpdateDate"];
        _lastSelectedSegmentControlIndex = [decoder decodeIntegerForKey:@"lastSelectedSegmentControlIndex"];
        
        self.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"News", @"") 
                                                         image:[UIImage imageNamed:@"56-feed.png"] 
                                                           tag:0];
        [self loadDataBasedOnSegmentControl];
    }
    return self;
}

@end
