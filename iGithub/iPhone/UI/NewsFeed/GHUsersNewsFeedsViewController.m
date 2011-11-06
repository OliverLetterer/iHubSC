//
//  GHUsersNewsFeedsViewController.m
//  iGithub
//
//  Created by Oliver Letterer on 06.11.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHUsersNewsFeedsViewController.h"
#import "UIColor+GithubUI.h"
#import "GHRepositoryViewController.h"
#import "GHUserViewController.h"
#import "GHNewOwnersNeedsFeedViewController.h"
#import "GHOwnersActionsNewsFeedViewController.h"
#import "GHOwnersOrganizationsNewsFeedViewController.h"



@implementation GHUsersNewsFeedsViewController
@synthesize segmentedControl=_segmentedControl;

#pragma mark - setters and getters

- (UISegmentedControl *)segmentedControl
{
    if (!_segmentedControl) {
        _segmentedControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:
                                                                       NSLocalizedString(@"News Feed", @""), 
                                                                       NSLocalizedString(@"My Actions", @""), 
                                                                       NSLocalizedString(@"Organizations", @""),
                                                                       nil]];
        _segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
    }
    return _segmentedControl;
}

#pragma mark - Initialization

- (id)init
{
    if (self = [super init]) {
        self.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"News", @"") 
                                                        image:[UIImage imageNamed:@"56-feed.png"] 
                                                          tag:0];
    }
    return self;
}

- (id)initAndDownloadData
{
    if (self = [self init]) {
        _downloadDataInViewDidLoad = YES;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        self.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"News", @"") 
                                                        image:[UIImage imageNamed:@"56-feed.png"] 
                                                          tag:0];
    }
    return self;
}

#pragma mark - View lifecycle

- (void)loadView 
{
    [super loadView];
    
    UIView *wrapperView = [[UIView alloc] initWithFrame:CGRectMake(17.0f, 6.0f, 286.0f, 32.0f)];
    [wrapperView addSubview:self.segmentedControl];
    self.navigationItem.titleView = wrapperView;
    
    _segmentedControl.userInteractionEnabled = YES;
    _segmentedControl.alpha = 1.0f;
    _segmentedControl.tintColor = [UIColor defaultNavigationBarTintColor];
    [_segmentedControl addTarget:self action:@selector(segmentControlValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    if (_downloadDataInViewDidLoad) {
        _downloadDataInViewDidLoad = NO;
        
        [self pullToReleaseTableViewReloadData];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    _segmentedControl = nil;
}

#pragma mark - Instance methods

- (void)segmentControlValueChanged:(UISegmentedControl *)segmentedControl
{
    UIViewController *replacementViewController = nil;
    
    if (segmentedControl.selectedSegmentIndex == 0) {
        replacementViewController = [[GHNewOwnersNeedsFeedViewController alloc] initAndDownloadData];
    } else if (segmentedControl.selectedSegmentIndex == 1) {
        replacementViewController = [[GHOwnersActionsNewsFeedViewController alloc] initAndDownloadData];
    } else if (segmentedControl.selectedSegmentIndex == 2) {
        replacementViewController = [[GHOwnersOrganizationsNewsFeedViewController alloc] initAndDownloadData];
    }
    
    if (replacementViewController) {
        NSMutableArray *viewControllers = self.navigationController.viewControllers.mutableCopy;
        NSInteger myIndex = [viewControllers indexOfObject:self];
        
        NSAssert(myIndex != NSNotFound, @"self.navigationController.viewControllers (%@) needs to contain %@", viewControllers, self);
        [viewControllers replaceObjectAtIndex:myIndex withObject:replacementViewController];
        
        self.navigationController.viewControllers = viewControllers;
    } else {
        DLog(@"segmentedControl.selectedSegmentIndex (%d) not supported", segmentedControl.selectedSegmentIndex);
    }
}

#pragma mark - Pull to release

- (void)pullToReleaseTableViewReloadData
{
    [super pullToReleaseTableViewReloadData];
    
    // update segmented control
    self.segmentedControl.alpha = 0.5f;
    self.segmentedControl.userInteractionEnabled = NO;
}

- (void)pullToReleaseTableViewDidReloadData
{
    [super pullToReleaseTableViewDidReloadData];
    
    self.segmentedControl.alpha = 1.0f;
    self.segmentedControl.userInteractionEnabled = YES;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectEvent:(GHAPIEventV3 *)event atIndexPath:(NSIndexPath *)indexPath
{
    UIViewController *viewController = nil;
    
    if (event.type == GHAPIEventTypeV3WatchEvent) {
        if ([event.repository.name hasPrefix:[GHAPIAuthenticationManager sharedInstance].authenticatedUser.login]) {
            // watched my repo, show the user
            viewController = [[GHUserViewController alloc] initWithUsername:event.actor.login];
        } else {
            // show me the repo that he is following
            viewController = [[GHRepositoryViewController alloc] initWithRepositoryString:event.repository.name];
        }
    } else if (event.type == GHAPIEventTypeV3FollowEvent) {
        GHAPIFollowEventV3 *followEvent = (GHAPIFollowEventV3 *)event;
        if ([followEvent.user.login isEqualToString:[GHAPIAuthenticationManager sharedInstance].authenticatedUser.login]) {
            // started following me, show me the user
            viewController = [[GHUserViewController alloc] initWithUsername:followEvent.actor.login];
        } else {
            // following someone else, show me the target
            viewController = [[GHUserViewController alloc] initWithUsername:followEvent.user.login];
        }
    } else if (event.type == GHAPIEventTypeV3ForkEvent) {
        if ([event.repository.name hasPrefix:[GHAPIAuthenticationManager sharedInstance].authenticatedUser.login]) {
            // forked my repository, show me the user
            viewController = [[GHUserViewController alloc] initWithUsername:event.actor.login];
        } else {
            // didn't fork my repo, show me the repo
            viewController = [[GHRepositoryViewController alloc] initWithRepositoryString:event.repository.name];
        }
    }
    
    if (viewController) {
        [self.navigationController pushViewController:viewController animated:YES];
    } else {
        [super tableView:tableView didSelectEvent:event atIndexPath:indexPath];
    }
}

@end
