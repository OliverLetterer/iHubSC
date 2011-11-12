//
//  GHPNewsFeedViewController.m
//  iGithub
//
//  Created by Oliver Letterer on 10.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHPNewsFeedViewController.h"
#import "GHPIssueViewController.h"
#import "GHPRepositoryViewController.h"
#import "GHPUserViewController.h"
#import "GHPGistViewController.h"
#import "GHPCommitsViewController.h"
#import "GHPCommitViewController.h"

#import "GHPDefaultNewsFeedTableViewCell.h"
#import "GHPNewsFeedSecondUserTableViewCell.h"

@implementation GHPNewsFeedViewController
@synthesize events=_events;

#pragma mark - setters and getters

- (void)setEvents:(NSMutableArray *)events
{
    if (events != _events) {
        _events = events;
        
        [self cacheHeightForTableView];
        if (self.isViewLoaded) {
            [self.tableView reloadData];
            [self scrollViewDidEndDecelerating:self.tableView];
        }
    }
}

#pragma mark - instance methods

- (void)downloadNewsFeed {
    
}

- (void)pullToReleaseTableViewReloadData {
    [super pullToReleaseTableViewReloadData];
    [self downloadNewsFeed];
}

- (void)cacheHeightForTableView
{
    [self.events enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        GHAPIEventV3 *event = obj;
        
        CGFloat height = 0.0f;
        NSString *description = [self descriptionForEvent:event];
        
        if (event.type == GHAPIEventTypeV3FollowEvent) {
            height = [GHPNewsFeedSecondUserTableViewCell heightWithContent:description];
        } else if (event.type == GHAPIEventTypeV3NewEvents) {
            height = 30.0f;
        } else {
            height = [GHPDefaultNewsFeedTableViewCell heightWithContent:description];
        }
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:idx inSection:0];
        
        [self cacheHeight:height forRowAtIndexPath:indexPath];
    }];
}

- (NSString *)descriptionForEvent:(GHAPIEventV3 *)event
{
    NSString *description = nil;
    
    if (event.type == GHAPIEventTypeV3IssuesEvent) {
        GHAPIIssuesEventV3 *myEvent = (GHAPIIssuesEventV3 *)event;
        
        description = [NSString stringWithFormat:NSLocalizedString(@"%@ Issue %@:\n\n%@", @""), myEvent.action, myEvent.issue.number, myEvent.issue.title];
    } else if (event.type == GHAPIEventTypeV3PushEvent) {
        GHAPIPushEventV3 *pushEvent = (GHAPIPushEventV3 *)event;
        // this is a commit / push message, we will display max 2 commits
        description = [NSString stringWithFormat:NSLocalizedString(@"pushed to %@ (%d)\n\n%@", @""), pushEvent.ref, pushEvent.commits.count, pushEvent.previewString];
    } else if(event.type == GHAPIEventTypeV3CommitComment) {
        GHAPICommitCommentEventV3 *commentEvent = (GHAPICommitCommentEventV3 *)event;
        description = commentEvent.comment.body;
    } else if(event.type == GHAPIEventTypeV3FollowEvent) {
        description = NSLocalizedString(@"started following", @"");
    } else if(event.type == GHAPIEventTypeV3WatchEvent) {
        GHAPIWatchEventV3 *watchEvent = (GHAPIWatchEventV3 *)event;
        description = [NSString stringWithFormat:NSLocalizedString(@"%@ watching", @""), watchEvent.action];
    } else if(event.type == GHAPIEventTypeV3CreateEvent) {
        GHAPICreateEventV3 *createEvent = (GHAPICreateEventV3 *)event;
        
        description = [NSString stringWithFormat:NSLocalizedString(@"created %@", @""), createEvent.createdObject];
        
        if (createEvent.objectName) {
            description = [description stringByAppendingFormat:@" %@", createEvent.objectName];
        }
    } else if(event.type == GHAPIEventTypeV3ForkEvent) {
        description = NSLocalizedString(@"forked repository", @"");
    } else if(event.type == GHAPIEventTypeV3DeleteEvent) {
        GHAPIDeleteEventV3 *deleteEvent = (GHAPIDeleteEventV3 *)event;
        description = [NSString stringWithFormat:NSLocalizedString(@"deleted %@ %@", @""), deleteEvent.objectType, deleteEvent.objectName];
    } else if(event.type == GHAPIEventTypeV3GollumEvent) {
        GHAPIGollumEventV3 *gollumEvent = (GHAPIGollumEventV3 *)event;
        
        NSMutableString *desctiptionString = [NSMutableString string];
        
        for (GHAPIGollumPageV3 *page in gollumEvent.pages) {
            [desctiptionString appendFormat:NSLocalizedString(@"%@ %@ in wiki\n", @""), page.action, page.pageName];
        }
        
        description = desctiptionString;
    } else if(event.type == GHAPIEventTypeV3GistEvent) {
        GHAPIGistEventV3 *gistEvent = (GHAPIGistEventV3 *)event;
        
        NSString *action = gistEvent.action;
        if ([action hasSuffix:@"e"]) {
            action = [action stringByAppendingString:@"d"];
        } else {
            action = [action stringByAppendingString:@"ed"];
        }
        
        description = [NSString stringWithFormat:@"%@ Gist %@:\n\n%@", action, gistEvent.gist.ID, gistEvent.gist.description];
    } else if(event.type == GHAPIEventTypeV3DownloadEvent) {
        GHAPIDownloadEventV3 *downloadEvent = (GHAPIDownloadEventV3 *)event;
        
        description = [NSString stringWithFormat:NSLocalizedString(@"created download: %@", @""), downloadEvent.download.name];
        if (downloadEvent.download.description) {
            description = [description stringByAppendingFormat:@"\n\n%@", downloadEvent.download.description];
        }
    } else if(event.type == GHAPIEventTypeV3PullRequestEvent) {
        GHAPIPullRequestEventV3 *pullEvent = (GHAPIPullRequestEventV3 *)event;
        
        NSString *additionsString = [NSString stringWithFormat:NSLocalizedString(@"%@ %@", @""), pullEvent.pullRequest.additions, [pullEvent.pullRequest.additions intValue] == 1 ? NSLocalizedString(@"addition", @"") : NSLocalizedString(@"additions", @"") ];
        NSString *deletionsString = [NSString stringWithFormat:NSLocalizedString(@"%@ %@", @""), pullEvent.pullRequest.deletions, [pullEvent.pullRequest.deletions intValue] == 1 ? NSLocalizedString(@"deletion", @"") : NSLocalizedString(@"deletions", @"") ];
        NSString *commitsString = [NSString stringWithFormat:NSLocalizedString(@"%@ %@", @""), pullEvent.pullRequest.commits, [pullEvent.pullRequest.commits intValue] == 1 ? NSLocalizedString(@"commit", @"") : NSLocalizedString(@"commits", @"") ];
        
        description = [NSString stringWithFormat:NSLocalizedString(@"%@ Pull Request %@\n\n%@\n\n%@ with %@ and %@", @""), pullEvent.action, pullEvent.pullRequest.ID, pullEvent.pullRequest.title, commitsString, additionsString, deletionsString];
    } else if(event.type == GHAPIEventTypeV3MemberEvent) {
        GHAPIMemberEventV3 *memberEvent = (GHAPIMemberEventV3 *)event;
        
        description = [NSString stringWithFormat:NSLocalizedString(@"%@ %@", @""), memberEvent.action, memberEvent.member.login];
    } else if(event.type == GHAPIEventTypeV3IssueCommentEvent) {
        GHAPIIssueCommentEventV3 *commentEvent = (GHAPIIssueCommentEventV3 *)event;
        
        
        description = [NSString stringWithFormat:NSLocalizedString(@"commented on Issue %@\n\n%@", @""), commentEvent.issue.number, commentEvent.issue.title ];
    } else if(event.type == GHAPIEventTypeV3ForkApplyEvent) {
        description = NSLocalizedString(@"applied fork commits", @"");
    } else if (event.type == GHAPIEventTypeV3PublicEvent) {
        description = NSLocalizedString(@"open sourced", @"");
    } else if (event.type == GHAPIEventTypeV3TeamAddEvent) {
        GHAPITeamAddEventV3 *addEvent = (GHAPITeamAddEventV3 *)event;
        
        if (addEvent.teamRepository.name) {
            description = [NSString stringWithFormat:@"added repository %@ to team %@", addEvent.teamRepository.name, addEvent.team.name];
        } else if (addEvent.teamUser.login) {
            description = [NSString stringWithFormat:@"added member %@ to team %@", addEvent.teamUser.login, addEvent.team.name];
        }
    }
    
    return description;
}

#pragma mark - Initialization

- (id)init {
    if ((self = [super initWithStyle:UITableViewStyleGrouped])) {
        // Custom initialization
        self.isDownloadingEssentialData = YES;
    }
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self downloadNewsFeed];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return _events.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GHAPIEventV3 *event = [_events objectAtIndex:indexPath.row];
    
    return [self tableView:tableView cellForEvent:event atIndexPath:indexPath];
}

- (UITableViewCell *)tableView:(UITableView *)tableView 
                  cellForEvent:(GHAPIEventV3 *)event 
                   atIndexPath:(NSIndexPath *)indexPath;
{
    if (event.type == GHAPIEventTypeV3IssuesEvent || event.type == GHAPIEventTypeV3PushEvent || event.type == GHAPIEventTypeV3CommitComment || event.type == GHAPIEventTypeV3WatchEvent || event.type == GHAPIEventTypeV3CreateEvent || event.type == GHAPIEventTypeV3ForkEvent || event.type == GHAPIEventTypeV3DeleteEvent || event.type == GHAPIEventTypeV3GollumEvent || event.type == GHAPIEventTypeV3GistEvent || event.type == GHAPIEventTypeV3DownloadEvent || event.type == GHAPIEventTypeV3PullRequestEvent || event.type == GHAPIEventTypeV3MemberEvent || event.type == GHAPIEventTypeV3IssueCommentEvent || event.type == GHAPIEventTypeV3ForkApplyEvent || event.type == GHAPIEventTypeV3PublicEvent || event.type == GHAPIEventTypeV3TeamAddEvent) {
        static NSString *CellIdentifier = @"GHPDefaultNewsFeedTableViewCell";
        GHPDefaultNewsFeedTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (!cell) {
            cell = [[GHPDefaultNewsFeedTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        [self setupDefaultTableViewCell:cell forRowAtIndexPath:indexPath];
        
        if (event.actor.avatarURL) {
            [self updateImageView:cell.imageView 
                      atIndexPath:indexPath 
              withAvatarURLString:event.actor.avatarURL];
        } else {
            [self updateImageView:cell.imageView 
                      atIndexPath:indexPath 
                   withGravatarID:event.actor.gravatarID];
        }
        
        cell.textLabel.text = event.actor.login;
        if (event.type == GHAPIEventTypeV3GistEvent) {
            cell.repositoryLabel.text = nil;
        } else {
            cell.repositoryLabel.text = event.repository.name;
        }
        cell.detailTextLabel.text = [self descriptionForEvent:event];
        cell.timeLabel.text = event.createdAtString.prettyShortTimeIntervalSinceNow;
        
        return cell;
    } else if (event.type == GHAPIEventTypeV3FollowEvent) {
        static NSString *CellIdentifier = @"GHPNewsFeedSecondUserTableViewCell";
        GHPNewsFeedSecondUserTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (!cell) {
            cell = [[GHPNewsFeedSecondUserTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        [self setupDefaultTableViewCell:cell forRowAtIndexPath:indexPath];
        
        if (event.actor.avatarURL) {
            [self updateImageView:cell.imageView 
                      atIndexPath:indexPath 
              withAvatarURLString:event.actor.avatarURL];
        } else {
            [self updateImageView:cell.imageView 
                      atIndexPath:indexPath 
                   withGravatarID:event.actor.gravatarID];
        }

        
        GHAPIFollowEventV3 *followEvent = (GHAPIFollowEventV3 *)event;
        
        cell.textLabel.text = followEvent.actor.login;
        cell.detailTextLabel.text = [self descriptionForEvent:event];
        cell.secondLabel.text = followEvent.user.login;
        cell.timeLabel.text = event.createdAtString.prettyShortTimeIntervalSinceNow;
        
        if (followEvent.user.avatarURL) {
            [self updateImageView:cell.secondImageView 
                      atIndexPath:indexPath 
              withAvatarURLString:followEvent.user.avatarURL];
        } else {
            [self updateImageView:cell.secondImageView 
                      atIndexPath:indexPath 
              withAvatarURLString:followEvent.user.gravatarID];
        }
        
        return cell;
    } else if (event.type == GHAPIEventTypeV3NewEvents) {
        static NSString *CellIdentifier = @"GHPDefaultTableViewCell";
        GHPDefaultTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (!cell) {
            cell = [[GHPDefaultTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.textLabel.textAlignment = UITextAlignmentCenter;
        }
        
        [self setupDefaultTableViewCell:cell forRowAtIndexPath:indexPath];
        
        GHAPINewEventsEventV3 *newMessagesEvent = (GHAPINewEventsEventV3 *)event;
        
        cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@ new Messages", @""), newMessagesEvent.numberOfNewEvents];
        
        return cell;
    }
    
    return [self dummyCellWithText:event.typeString];
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self cachedHeightForRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectEvent:(GHAPIEventV3 *)event atIndexPath:(NSIndexPath *)indexPath
{
    UIViewController *viewController = nil;
    
    if (event.type == GHAPIEventTypeV3IssuesEvent) {
        GHAPIIssuesEventV3 *myEvent = (GHAPIIssuesEventV3 *)event;
        
        viewController = [[GHPIssueViewController alloc] initWithIssueNumber:myEvent.issue.number onRepository:event.repository.name];
    } else if (event.type == GHAPIEventTypeV3PushEvent) {
        GHAPIPushEventV3 *pushEvent = (GHAPIPushEventV3 *)event;
        
        viewController = [[GHPCommitsViewController alloc] initWithRepository:event.repository.name 
                                                                      commits:pushEvent.commits];
    } else if(event.type == GHAPIEventTypeV3CommitComment) {
        viewController = [[GHPRepositoryViewController alloc] initWithRepositoryString:event.repository.name];
    } else if(event.type == GHAPIEventTypeV3FollowEvent) {
        GHAPIFollowEventV3 *followEvent = (GHAPIFollowEventV3 *)event;
        
        viewController = [[GHPUserViewController alloc] initWithUsername:followEvent.user.login];
    } else if(event.type == GHAPIEventTypeV3WatchEvent) {
        GHAPIWatchEventV3 *watchEvent = (GHAPIWatchEventV3 *)event;
        
        viewController = [[GHPRepositoryViewController alloc] initWithRepositoryString:watchEvent.repository.name];
    } else if(event.type == GHAPIEventTypeV3CreateEvent) {
        GHAPICreateEventV3 *createEvent = (GHAPICreateEventV3 *)event;
        
        viewController = [[GHPRepositoryViewController alloc] initWithRepositoryString:createEvent.repository.name];
    } else if(event.type == GHAPIEventTypeV3ForkEvent) {
        viewController = [[GHPRepositoryViewController alloc] initWithRepositoryString:event.repository.name];
    } else if(event.type == GHAPIEventTypeV3DeleteEvent) {
        GHAPIDeleteEventV3 *deleteEvent = (GHAPIDeleteEventV3 *)event;
        
        viewController = [[GHPRepositoryViewController alloc] initWithRepositoryString:deleteEvent.repository.name];
    } else if(event.type == GHAPIEventTypeV3GollumEvent) {
        viewController = [[GHPRepositoryViewController alloc] initWithRepositoryString:event.repository.name];
    } else if(event.type == GHAPIEventTypeV3GistEvent) {
        GHAPIGistEventV3 *gistEvent = (GHAPIGistEventV3 *)event;
        
        viewController = [[GHPGistViewController alloc] initWithGistID:gistEvent.gist.ID];
    } else if(event.type == GHAPIEventTypeV3DownloadEvent) {
        GHAPIDownloadEventV3 *downloadEvent = (GHAPIDownloadEventV3 *)event;
        
        viewController = [[GHPRepositoryViewController alloc] initWithRepositoryString:downloadEvent.repository.name];
    } else if(event.type == GHAPIEventTypeV3PullRequestEvent) {
        GHAPIPullRequestEventV3 *pullEvent = (GHAPIPullRequestEventV3 *)event;
        
        viewController = [[GHPIssueViewController alloc] initWithIssueNumber:pullEvent.pullRequest.ID onRepository:event.repository.name];
    } else if(event.type == GHAPIEventTypeV3MemberEvent) {
        GHAPIMemberEventV3 *memberEvent = (GHAPIMemberEventV3 *)event;
        
        viewController = [[GHPUserViewController alloc] initWithUsername:memberEvent.member.login];
    } else if(event.type == GHAPIEventTypeV3IssueCommentEvent) {
        GHAPIIssueCommentEventV3 *commentEvent = (GHAPIIssueCommentEventV3 *)event;
        
        viewController = [[GHPIssueViewController alloc] initWithIssueNumber:commentEvent.issue.number onRepository:event.repository.name];
    } else if(event.type == GHAPIEventTypeV3ForkApplyEvent) {
        viewController = [[GHPRepositoryViewController alloc] initWithRepositoryString:event.repository.name];
    } else if (event.type == GHAPIEventTypeV3PublicEvent) {
        viewController = [[GHPRepositoryViewController alloc] initWithRepositoryString:event.repository.name];
    } else if (event.type == GHAPIEventTypeV3TeamAddEvent) {
        GHAPITeamAddEventV3 *addEvent = (GHAPITeamAddEventV3 *)event;
        
        if (addEvent.teamRepository.name) {
            viewController = [[GHPRepositoryViewController alloc] initWithRepositoryString:addEvent.teamRepository.name];
        } else if (addEvent.teamUser.login) {
            viewController = [[GHPUserViewController alloc] initWithUsername:addEvent.teamUser.login];
        }
    }
    
    if (viewController) {
        [self.advancedNavigationController pushViewController:viewController afterViewController:self animated:YES];
    } else {
        [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    }

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    GHAPIEventV3 *event = [_events objectAtIndex:indexPath.row];
    [self tableView:tableView didSelectEvent:event atIndexPath:indexPath];
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)encoder 
{
    [super encodeWithCoder:encoder];
    [encoder encodeObject:_events forKey:@"events"];
}

- (id)initWithCoder:(NSCoder *)decoder 
{
    if (self = [super initWithCoder:decoder]) {
        _events = [decoder decodeObjectForKey:@"events"];
    }
    return self;
}

@end
