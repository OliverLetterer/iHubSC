//
//  GHPOwnersNewsFeedViewController.m
//  iGithub
//
//  Created by Oliver Letterer on 10.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHPOwnersNewsFeedViewController.h"
#import "GHPUserViewController.h"
#import "GHPRepositoryViewController.h"

@interface GHPOwnersNewsFeedViewController ()

@property (nonatomic, strong) NSString *lastKnownEventDateString;
@property (nonatomic, readonly) BOOL isShowingNewMessagesIndicator;

- (void)_showNewMessagesIndicatorBeforeEvent:(GHAPIEventV3 *)event;
- (void)_hideNewMessagesIndicator;

@end





@implementation GHPOwnersNewsFeedViewController
@synthesize lastKnownEventDateString=_lastKnownEventDateString;

#pragma mark - setters and getters

- (BOOL)isShowingNewMessagesIndicator
{
    BOOL isShowingNewMessagesIndicator = [_events indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        GHAPIEventV3 *event = obj;
        
        *stop = (event.type == GHAPIEventTypeV3NewEvents);
        return *stop;
    }] != NSNotFound;
    
    return isShowingNewMessagesIndicator;
}

#pragma mark - initialization

- (id)init {
    if (self = [super init]) {
        self.reloadDataOnApplicationWillEnterForeground = YES;
        self.reloadDataIfNewUserGotAuthenticated = YES;
    }
    return self;
}

#pragma mark - Downloading

- (void)downloadNewsFeed { }

- (void)pullToReleaseTableViewReloadData
{
    [super pullToReleaseTableViewReloadData];
    
    if (!_isDownloadingNewsFeedData) {
        [self downloadNewEventsAfterLastKnownEventDateString:self.lastKnownEventDateString];
    }
}

- (void)downloadNewEventsAfterLastKnownEventDateString:(NSString *)lastKnownEventDateString
{
    if (!_events) {
        self.isDownloadingEssentialData = YES;
    }
    
    _isDownloadingNewsFeedData = YES;
    
    [GHAPIEventV3 eventsForAuthenticatedUserSinceLastEventDateString:lastKnownEventDateString 
                                                   completionHandler:^(NSArray *events, NSError *error) {
                                                       if (error) {
                                                           [self handleError:error];
                                                       } else {
                                                           [self appendNewEvents:events];
                                                       }
                                                       
                                                       self.isDownloadingEssentialData = NO;
                                                       [self pullToReleaseTableViewDidReloadData];
                                                       
                                                       _isDownloadingNewsFeedData = NO;
                                                   }];
}

- (void)appendNewEvents:(NSArray *)newEvents
{
    if (!_events) {
        _events = [NSMutableArray array];
    }
    
    NSInteger index = [_events indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        GHAPIEventV3 *event = obj;
        
        *stop = [event.createdAtString isEqualToString:self.lastKnownEventDateString];
        return *stop;
    }];
    
    GHAPIEventV3 *lastKnownEvent = nil;
    if (index != NSNotFound) {
        lastKnownEvent = [_events objectAtIndex:index];
    }
    
    GHAPIEventV3 *topVisibleEvent = nil;
    CGFloat topVisibleCellInset = 0.0f;
    if (self.isViewLoaded) {
        NSArray *visibleIndexPaths = [self.tableView indexPathsForVisibleRows];
        if (visibleIndexPaths.count > 0) {
            NSIndexPath *topVisibleIndexPath = [visibleIndexPaths objectAtIndex:0];
            
            CGRect topVisibleTableViewCellFrame = [self.tableView rectForRowAtIndexPath:topVisibleIndexPath];
            topVisibleCellInset = CGRectGetMinY(self.tableView.bounds) - CGRectGetMinY(topVisibleTableViewCellFrame);
            
            topVisibleEvent = [_events objectAtIndex:topVisibleIndexPath.row];
        }
    }
    
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, newEvents.count)];
    
    [_events insertObjects:newEvents atIndexes:indexSet];
    [self cacheHeightForTableView];
    
    if (self.isViewLoaded) {
        [self.tableView reloadData];
        
        if (topVisibleEvent) {
            NSInteger indexOfLastTopVisibleEvent = [_events indexOfObject:topVisibleEvent];
            NSIndexPath *lastTopVisibleIndexPath = [NSIndexPath indexPathForRow:indexOfLastTopVisibleEvent inSection:0];
            
            CGRect topVisibleTableViewCellFrame = [self.tableView rectForRowAtIndexPath:lastTopVisibleIndexPath];
            
            CGFloat contentOffsetY = CGRectGetMinY(topVisibleTableViewCellFrame) + topVisibleCellInset;
            [self.tableView setContentOffset:CGPointMake(0.0f, contentOffsetY) animated:NO];
        }
    }
    
    if (lastKnownEvent && [_events indexOfObject:lastKnownEvent] != 0) {
        [self _showNewMessagesIndicatorBeforeEvent:lastKnownEvent];
    } else {
        [self _hideNewMessagesIndicator];
    }
    
    if (_events.count > 0) {
        GHAPIEventV3 *event = [_events objectAtIndex:0];
        self.lastKnownEventDateString = event.createdAtString;
    }
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self downloadNewEventsAfterLastKnownEventDateString:self.lastKnownEventDateString];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectEvent:(GHAPIEventV3 *)event atIndexPath:(NSIndexPath *)indexPath
{
    UIViewController *viewController = nil;
    
    if (event.type == GHAPIEventTypeV3WatchEvent) {
        if ([event.repository.name hasPrefix:[GHAPIAuthenticationManager sharedInstance].authenticatedUser.login]) {
            // watched my repo, show the user
            viewController = [[GHPUserViewController alloc] initWithUsername:event.actor.login];
        } else {
            // show me the repo that he is following
            viewController = [[GHPRepositoryViewController alloc] initWithRepositoryString:event.repository.name];
        }
    } else if (event.type == GHAPIEventTypeV3FollowEvent) {
        GHAPIFollowEventV3 *followEvent = (GHAPIFollowEventV3 *)event;
        if ([followEvent.user.login isEqualToString:[GHAPIAuthenticationManager sharedInstance].authenticatedUser.login]) {
            // started following me, show me the user
            viewController = [[GHPUserViewController alloc] initWithUsername:followEvent.actor.login];
        } else {
            // following someone else, show me the target
            viewController = [[GHPUserViewController alloc] initWithUsername:followEvent.user.login];
        }
    } else if (event.type == GHAPIEventTypeV3ForkEvent) {
        if ([event.repository.name hasPrefix:[GHAPIAuthenticationManager sharedInstance].authenticatedUser.login]) {
            // forked my repository, show me the user
            viewController = [[GHPUserViewController alloc] initWithUsername:event.actor.login];
        } else {
            // didn't fork my repo, show me the repo
            viewController = [[GHPRepositoryViewController alloc] initWithRepositoryString:event.repository.name];
        }
    }
    
    if (viewController) {
        [self.advancedNavigationController pushViewController:viewController afterViewController:self animated:YES];
    } else {
        [super tableView:tableView didSelectEvent:event atIndexPath:indexPath];
    }
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)encoder 
{
    [super encodeWithCoder:encoder];
    [encoder encodeObject:_lastKnownEventDateString forKey:@"lastKnownEventDateString"];
}

- (id)initWithCoder:(NSCoder *)decoder 
{
    if (self = [super initWithCoder:decoder]) {
        _lastKnownEventDateString = [decoder decodeObjectForKey:@"lastKnownEventDateString"];
    }
    return self;
}

#pragma mark - private implementation ()

- (void)_showNewMessagesIndicatorBeforeEvent:(GHAPIEventV3 *)event
{
    if (event.type == GHAPIEventTypeV3NewEvents) {
        return;
    }
    
    if (self.isShowingNewMessagesIndicator) {
        [self _hideNewMessagesIndicator];
    }
    
    NSInteger row = [_events indexOfObject:event];
    
    if (row != NSNotFound) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
        NSArray *indexPaths = [NSArray arrayWithObject:indexPath];
        
        GHAPINewEventsEventV3 *newMessagesEvents = [[GHAPINewEventsEventV3 alloc] init];
        newMessagesEvents.numberOfNewEvents = [NSNumber numberWithInt:row];
        
        [_events insertObject:newMessagesEvents atIndex:row];
        [self cacheHeightForTableView];
        
        [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationTop];
    } else {
        NSAssert(NO, @"_events need to contain event %@", event);
    }
}

- (void)_hideNewMessagesIndicator
{
    if (!self.isShowingNewMessagesIndicator) {
        return;
    } else {
        NSInteger row = [_events indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
            GHAPIEventV3 *event = obj;
            
            *stop = (event.type == GHAPIEventTypeV3NewEvents);
            return *stop;
        }];
        
        if (row != NSNotFound) {
            // we found the newMessages Event. Now remove it from our database and UI
            [_events removeObjectAtIndex:row];
            [self cacheHeightForTableView];
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
            NSArray *indexPaths = [NSArray arrayWithObject:indexPath];
            
            @try {
                [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationTop];
            }
            @catch (NSException *exception) {
                [self.tableView reloadData];
            }
        } else {
            NSAssert(NO, @"_events needs to contain an event of type GHAPIEventTypeV3NewEvents");
        }
    }
}

@end
