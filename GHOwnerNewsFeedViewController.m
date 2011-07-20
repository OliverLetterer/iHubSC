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
#import "GHSettingsHelper.h"
#import "GHFeedItemWithDescriptionTableViewCell.h"
#import "GHPushFeedItemTableViewCell.h"
#import "GHFollowEventTableViewCell.h"
#import "GHViewIssueTableViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "UIColor+GithubUI.h"

#import "GHUserViewController.h"
#import "GHSingleRepositoryViewController.h"

#define GHOwnerNewsFeedViewControllerDefaultOrganizationNameKey @"GHOwnerNewsFeedViewControllerDefaultOrganizationName"
#define GHOwnerNewsFeedViewControllerLastCreationDateKey @"GHOwnerNewsFeedViewControllerLastCreationDate"

@implementation GHOwnerNewsFeedViewController

@synthesize segmentControl=_segmentControl, stateSegmentControl=_stateSegmentControl;
@synthesize organizations=_organizations, defaultOrganizationName=_defaultOrganizationName, lastCreationDate=_lastCreationDate;
@synthesize pendingStateStringsArray=_pendingStateStringsArray, lastStateUpdateDate=_lastStateUpdateDate;

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
        self.pendingStateStringsArray = [NSMutableArray array];
    }
    return self;
}

#pragma mark - Memory management

- (void)dealloc {
    [_stateSegmentControl release];
    [_segmentControl release];
    [_organizations release];
    [_defaultOrganizationName release];
    [_lastCreationDate release];
    [_pendingStateStringsArray release];
    [_lastStateUpdateDate release];
    
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
    
    UIView *wrapperView = [[[UIView alloc] initWithFrame:CGRectMake(17.0f, 6.0f, 286.0f, 32.0f)] autorelease];
    self.segmentControl = [[[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:
                                                                      NSLocalizedString(@"News Feed", @""), 
                                                                      NSLocalizedString(@"My Actions", @""), 
                                                                      NSLocalizedString(@"Organizations", @""),
                                                                      nil]] 
                           autorelease];
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
    [self.segmentControl addTarget:self action:@selector(segmentControlValueChanged:) forControlEvents:UIControlEventValueChanged];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (!self.newsFeed) {
        self.newsFeed = [self loadSerializedNewsFeed];
        [self pullToReleaseTableViewReloadData];
    }
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    [_segmentControl release];
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
    // download new data
    if (self.segmentControl.selectedSegmentIndex == 0) {
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
                self.newsFeed = feed;
                [self serializeNewsFeed:feed];
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
                           self.isDownloadingEssentialData = NO;
                           if (error) {
                               [self detachNewStateString:NSLocalizedString(@"Error", @"") removeAfterDisplayed:YES];
                               self.segmentControl.userInteractionEnabled = YES;
                               self.segmentControl.alpha = 1.0;
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
                self.isDownloadingEssentialData = NO;
                if (error) {
                    [self detachNewStateString:NSLocalizedString(@"Error", @"") removeAfterDisplayed:YES];
                    self.segmentControl.userInteractionEnabled = YES;
                    self.segmentControl.alpha = 1.0;
                    [self handleError:error];
                } else {
                    self.newsFeed = feed;
                    [self serializeNewsFeed:feed];
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
                                       self.isDownloadingEssentialData = NO;
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
                                           [self loadDataBasedOnSegmentControl];
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
            [self detachNewStateString:NSLocalizedString(@"Error", @"") removeAfterDisplayed:YES];
            self.segmentControl.userInteractionEnabled = YES;
            self.segmentControl.alpha = 1.0;
            [self handleError:error];
        } else {
            self.newsFeed = feed;
            [self serializeNewsFeed:feed];
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
        if ([item.repository.fullName hasPrefix:[GHAuthenticationManager sharedInstance].username]) {
            // watched my repo, show the user
            viewController = [[[GHUserViewController alloc] initWithUsername:item.actorAttributes.login] autorelease];
        } else {
            // show me the repo that he is following
            viewController = [[[GHSingleRepositoryViewController alloc] initWithRepositoryString:item.repository.fullName] autorelease];
        }
    } else if (item.payload.type == GHPayloadFollowEvent) {
        GHFollowEventPayload *payload = (GHFollowEventPayload *)item.payload;
        if ([payload.target.login isEqualToString:[GHAuthenticationManager sharedInstance].username]) {
            // started following me, show me the user
            viewController = [[[GHUserViewController alloc] initWithUsername:item.actorAttributes.login] autorelease];
        } else {
            // following someone else, show me the target
            viewController = [[[GHUserViewController alloc] initWithUsername:payload.target.login] autorelease];
        }
    } else if (item.payload.type == GHPayloadForkEvent) {
        if ([item.repository.fullName hasPrefix:[GHAuthenticationManager sharedInstance].username]) {
            // forked my repository, show me the user
            viewController = [[[GHUserViewController alloc] initWithUsername:item.actorAttributes.login] autorelease];
        } else {
            // didn't fork my repo, show me the repo
            viewController = [[[GHSingleRepositoryViewController alloc] initWithRepositoryString:item.repository.fullName] autorelease];
        }
    }
    
    if (viewController) {
        [self.navigationController pushViewController:viewController animated:YES];
    } else {
        [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    }
}

@end






NSString *const NewsFeedSerializationFileName = @"de.olettere.lastKnownNewsFeed.plist";

@implementation GHOwnerNewsFeedViewController (GHOwnerNewsFeedViewControllerSerializaiton)

- (void)serializeNewsFeed:(GHNewsFeed *)newsFeed {
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:NewsFeedSerializationFileName];
    
    [NSKeyedArchiver archiveRootObject:newsFeed toFile:filePath];
}

- (GHNewsFeed *)loadSerializedNewsFeed {
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:NewsFeedSerializationFileName];
    
    return [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
}

@end

