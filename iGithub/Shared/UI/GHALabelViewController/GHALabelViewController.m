//
//  GHALabelViewController.m
//  iGithub
//
//  Created by Oliver Letterer on 09.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHALabelViewController.h"


@implementation GHALabelViewController

@synthesize repositoryString=_repositoryString;
@synthesize label=_label;
@synthesize openIssues=_openIssues, closedIssues=_closedIssues;

#pragma mark - Initialization

- (id)initWithRepository:(NSString *)repository label:(GHAPILabelV3 *)label {
    if ((self = [super initWithStyle:UITableViewStylePlain])) {
        // Custom initialization
        self.repositoryString = repository;
        self.label = label;
    }
    return self;
}

#pragma mark - setters and getters

- (void)setLabel:(GHAPILabelV3 *)label {
    if (label != _label) {
        _label = label;
        
        self.title = label.name;
    }
}

#pragma mark - Notifications

- (void)issueChangedNotificationCallback:(NSNotification *)notification {
    GHAPIIssueV3 *issue = [notification.userInfo objectForKey:GHAPIV3NotificationUserDictionaryIssueKey];
    BOOL changed = NO;
    
    // issue now has this milestone -> add based on state
    // issue changed state without milestone -> swap in arrays
    // issue was present but milestone changed -> remove
    
    if ([issue.labels containsObject:self.label]) {
        // issue belongs here
        if ([self.openIssues containsObject:issue] && !issue.isOpen) {
            // state changed
            [self.openIssues removeObject:issue];
            [self.closedIssues insertObject:issue atIndex:0];
            changed = YES;
        } else if ([self.closedIssues containsObject:issue] && issue.isOpen) {
            // state changed
            [self.closedIssues removeObject:issue];
            [self.openIssues insertObject:issue atIndex:0];
            changed = YES;
        } else {
            if ([issue.state isEqualToString:kGHAPIIssueStateV3Closed]) {
                [self.closedIssues insertObject:issue atIndex:0];
                changed = YES;
            } else {
                [self.openIssues insertObject:issue atIndex:0];
                changed = YES;
            }
        }
    } else {
        // issue doesnt belong here
        if ([self.openIssues containsObject:issue]) {
            [self.openIssues removeObject:issue];
            changed = YES;
        }
        if ([self.closedIssues containsObject:issue]) {
            [self.closedIssues removeObject:issue];
            changed = YES;
        }
    }
    
    if (changed) {
        [self cacheHeightForOpenIssuesArray];
        [self cacheHeightForClosedIssuesArray];
        if (self.isViewLoaded) {
            [self.tableView reloadDataAndResetExpansionStates:NO];
        }
    }
}

#warning contains issue - update

- (void)issueCreationNotificationCallback:(NSNotification *)notification {
    GHAPIIssueV3 *issue = [notification.userInfo objectForKey:GHAPIV3NotificationUserDictionaryIssueKey];
    BOOL changed = NO;
    
    if ([issue.labels containsObject:self.label]) {
        if (issue.isOpen) {
            [self.openIssues insertObject:issue atIndex:0];
        } else {
            [self.closedIssues insertObject:issue atIndex:0];
        }
        changed = YES;
    }
    
    if (changed) {
        [self cacheHeightForOpenIssuesArray];
        [self cacheHeightForClosedIssuesArray];
        if (self.isViewLoaded) {
            [self.tableView reloadDataAndResetExpansionStates:NO];
        }
    }
}

#pragma mark - Height Caching

- (void)cacheHeightForOpenIssuesArray {
    
}

- (void)cacheHeightForClosedIssuesArray {
    
}

#pragma mark - Keyed Archiving

- (void)encodeWithCoder:(NSCoder *)encoder {
    [super encodeWithCoder:encoder];
    [encoder encodeObject:_repositoryString forKey:@"repositoryString"];
    [encoder encodeObject:_label forKey:@"label"];
    [encoder encodeObject:_openIssues forKey:@"openIssues"];
    [encoder encodeObject:_closedIssues forKey:@"closedIssues"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super initWithCoder:decoder])) {
        _repositoryString = [decoder decodeObjectForKey:@"repositoryString"];
        self.label = [decoder decodeObjectForKey:@"label"];
        _openIssues = [decoder decodeObjectForKey:@"openIssues"];
        _closedIssues = [decoder decodeObjectForKey:@"closedIssues"];
    }
    return self;
}

@end
