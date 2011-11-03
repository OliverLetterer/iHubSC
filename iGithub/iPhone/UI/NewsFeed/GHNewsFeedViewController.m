//
//  GHNewsFeedViewController.m
//  iGithub
//
//  Created by Oliver Letterer on 30.03.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHNewsFeedViewController.h"
#import "GithubAPI.h"
#import "GHDescriptionTableViewCell.h"
#import "GHFollowEventTableViewCell.h"
#import "GHIssueViewController.h"
#import "GHPushPayloadViewController.h"
#import "GHRepositoryViewController.h"
#import "GHUserViewController.h"
#import "GHGistViewController.h"

@implementation GHNewsFeedViewController
@synthesize events=_events;

#pragma mark - setters and getters

- (void)setEvents:(NSArray *)events
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

#pragma mark - Initialization

- (id)init 
{
    if ((self = [super initWithStyle:UITableViewStylePlain])) {
        // Custom initialization
        self.pullToReleaseEnabled = YES;
    }
    return self;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    // Return the number of rows in the section.
    return _events.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView 
                  cellForEvent:(GHAPIEventV3 *)event 
                   atIndexPath:(NSIndexPath *)indexPath;
{
    if (event.type == GHAPIEventTypeV3IssuesEvent || event.type == GHAPIEventTypeV3PushEvent || event.type == GHAPIEventTypeV3CommitComment || event.type == GHAPIEventTypeV3WatchEvent || event.type == GHAPIEventTypeV3CreateEvent || event.type == GHAPIEventTypeV3ForkEvent || event.type == GHAPIEventTypeV3DeleteEvent || event.type == GHAPIEventTypeV3GollumEvent || event.type == GHAPIEventTypeV3GistEvent || event.type == GHAPIEventTypeV3DownloadEvent || event.type == GHAPIEventTypeV3PullRequestEvent || event.type == GHAPIEventTypeV3MemberEvent || event.type == GHAPIEventTypeV3IssueCommentEvent || event.type == GHAPIEventTypeV3ForkApplyEvent || event.type == GHAPIEventTypeV3PublicEvent || event.type == GHAPIEventTypeV3TeamAddEvent) {
        static NSString *CellIdentifier = @"GHFeedItemWithDescriptionTableViewCell";
        GHDescriptionTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (!cell) {
            cell = [[GHDescriptionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
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
        cell.detailTextLabel.text = event.repository.name;
        cell.timeLabel.text = event.createdAtString.prettyShortTimeIntervalSinceNow;
        cell.descriptionLabel.text = [self descriptionForEvent:event];
        
        return cell;
    } else if (event.type == GHAPIEventTypeV3FollowEvent) {
        static NSString *CellIdentifier = @"GHFollowEventTableViewCell";
        GHFollowEventTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (!cell) {
            cell = [[GHFollowEventTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
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
        cell.descriptionLabel.text = [self descriptionForEvent:event];
        cell.targetNameLabel.text = followEvent.user.login;
        cell.timeLabel.text = event.createdAtString.prettyShortTimeIntervalSinceNow;
        
        [self updateImageView:cell.targetImageView 
                  atIndexPath:indexPath 
          withAvatarURLString:followEvent.user.avatarURL];
        
        return cell;
    }
    
    return [self dummyCellWithText:event.typeString];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    GHAPIEventV3 *event = [_events objectAtIndex:indexPath.row];
    
    return [self tableView:tableView cellForEvent:event atIndexPath:indexPath];
}

#pragma mark - instance methods

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
#warning add more details here
        description = NSLocalizedString(@"commented on a commit", @"");
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
        
        description = [NSString stringWithFormat:NSLocalizedString(@"%@ Pull Request %@\n\n%@", @""), pullEvent.action, pullEvent.pullRequest.number, pullEvent.pullRequest.title];
        
#warning maybe add additions and deletions as info
//        NSString *additionsString = [NSString stringWithFormat:NSLocalizedString(@"%@ %@", @""), payload.pullRequest.additions, [payload.pullRequest.additions intValue] == 1 ? NSLocalizedString(@"addition", @"") : NSLocalizedString(@"additions", @"") ];
//        NSString *deletionsString = [NSString stringWithFormat:NSLocalizedString(@"%@ %@", @""), payload.pullRequest.deletions, [payload.pullRequest.deletions intValue] == 1 ? NSLocalizedString(@"deletion", @"") : NSLocalizedString(@"deletions", @"") ];
//        NSString *commitsString = [NSString stringWithFormat:NSLocalizedString(@"%@ %@", @""), payload.pullRequest.commits, [payload.pullRequest.commits intValue] == 1 ? NSLocalizedString(@"commit", @"") : NSLocalizedString(@"commits", @"") ];
//        
//        description = [NSString stringWithFormat:NSLocalizedString(@"%@ with %@ and %@", @""), commitsString, additionsString, deletionsString];
//        
//        if (payload.pullRequest) {
//            
//        }
//        description = [NSString stringWithFormat:NSLocalizedString(@"%@ pull request %@:\n\n%@\n\n%@", @""), payload.action, payload.number, payload.pullRequest.title, description];
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

- (void)cacheHeightForTableView {
    int i = 0;
    for (GHAPIEventV3 *event in _events) {
        CGFloat height = 0.0;
        CGFloat minimumHeight = 0.0;
        
#ifdef DEBUG
        minimumHeight = 15.0f;
#endif
        
        NSString *description = [self descriptionForEvent:event];
        if (event.type == GHAPIEventTypeV3FollowEvent) {
            height = [GHFollowEventTableViewCell heightWithContent:description];
        } else {
            height = [GHDescriptionTableViewCell heightWithContent:description];
        }
        
        [self cacheHeight:height < minimumHeight ? minimumHeight : height forRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        i++;
    }
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    return [self cachedHeightForRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView 
   didSelectEvent:(GHAPIEventV3 *)event 
      atIndexPath:(NSIndexPath *)indexPath
{
    UIViewController *viewController = nil;
    
    if (event.type == GHAPIEventTypeV3IssuesEvent) {
        GHAPIIssuesEventV3 *myEvent = (GHAPIIssuesEventV3 *)event;
        
        viewController = [[GHIssueViewController alloc] 
                          initWithRepository:myEvent.repository.name 
                          issueNumber:myEvent.issue.number];
    } else if (event.type == GHAPIEventTypeV3PushEvent) {
        GHAPIPushEventV3 *pushEvent = (GHAPIPushEventV3 *)event;
        
#warning we need a new viewController to display pushed commits on iPhone
        //        GHPushPayloadViewController *pushViewController = [[GHPushPayloadViewController alloc] initWithPayload:(GHPushPayload *)item.payload onRepository:item.repository.fullName];
        //        [self.navigationController pushViewController:pushViewController animated:YES];
    } else if(event.type == GHAPIEventTypeV3CommitComment) {
#warning check for more details
        viewController = [[GHRepositoryViewController alloc] initWithRepositoryString:event.repository.name];
    } else if(event.type == GHAPIEventTypeV3FollowEvent) {
        GHAPIFollowEventV3 *followEvent = (GHAPIFollowEventV3 *)event;
        
        viewController = [[GHUserViewController alloc] initWithUsername:followEvent.user.login];
    } else if(event.type == GHAPIEventTypeV3WatchEvent) {
        GHAPIWatchEventV3 *watchEvent = (GHAPIWatchEventV3 *)event;
        
        viewController = [[GHRepositoryViewController alloc] initWithRepositoryString:watchEvent.repository.name];
    } else if(event.type == GHAPIEventTypeV3CreateEvent) {
        GHAPICreateEventV3 *createEvent = (GHAPICreateEventV3 *)event;
        
        viewController = [[GHRepositoryViewController alloc] initWithRepositoryString:createEvent.repository.name];
    } else if(event.type == GHAPIEventTypeV3ForkEvent) {
        viewController = [[GHRepositoryViewController alloc] initWithRepositoryString:event.repository.name];
    } else if(event.type == GHAPIEventTypeV3DeleteEvent) {
        GHAPIDeleteEventV3 *deleteEvent = (GHAPIDeleteEventV3 *)event;
        
        viewController = [[GHRepositoryViewController alloc] initWithRepositoryString:deleteEvent.repository.name];
    } else if(event.type == GHAPIEventTypeV3GollumEvent) {
        viewController = [[GHRepositoryViewController alloc] initWithRepositoryString:event.repository.name];
    } else if(event.type == GHAPIEventTypeV3GistEvent) {
        GHAPIGistEventV3 *gistEvent = (GHAPIGistEventV3 *)event;
        
        viewController = [[GHGistViewController alloc] initWithID:gistEvent.gist.ID];
    } else if(event.type == GHAPIEventTypeV3DownloadEvent) {
        GHAPIDownloadEventV3 *downloadEvent = (GHAPIDownloadEventV3 *)event;
        
        viewController = [[GHRepositoryViewController alloc] initWithRepositoryString:downloadEvent.repository.name];
    } else if(event.type == GHAPIEventTypeV3PullRequestEvent) {
        GHAPIPullRequestEventV3 *pullEvent = (GHAPIPullRequestEventV3 *)event;
        
        viewController = [[GHIssueViewController alloc] initWithRepository:pullEvent.repository.name issueNumber:pullEvent.pullRequest.number];
    } else if(event.type == GHAPIEventTypeV3MemberEvent) {
        GHAPIMemberEventV3 *memberEvent = (GHAPIMemberEventV3 *)event;
        
        viewController = [[GHUserViewController alloc] initWithUsername:memberEvent.member.login];
    } else if(event.type == GHAPIEventTypeV3IssueCommentEvent) {
        GHAPIIssueCommentEventV3 *commentEvent = (GHAPIIssueCommentEventV3 *)event;
        
        viewController = [[GHIssueViewController alloc] initWithRepository:commentEvent.repository.name issueNumber:commentEvent.issue.number];
    } else if(event.type == GHAPIEventTypeV3ForkApplyEvent) {
        viewController = [[GHRepositoryViewController alloc] initWithRepositoryString:event.repository.name];
    } else if (event.type == GHAPIEventTypeV3PublicEvent) {
        viewController = [[GHRepositoryViewController alloc] initWithRepositoryString:event.repository.name];
    } else if (event.type == GHAPIEventTypeV3TeamAddEvent) {
        GHAPITeamAddEventV3 *addEvent = (GHAPITeamAddEventV3 *)event;
        
        if (addEvent.teamRepository.name) {
            viewController = [[GHRepositoryViewController alloc] initWithRepositoryString:addEvent.teamRepository.name];
        } else if (addEvent.teamUser.login) {
            viewController = [[GHUserViewController alloc] initWithUsername:addEvent.teamUser.name];
        }
    }
    
    if (viewController) {
        [self.navigationController pushViewController:viewController animated:YES];
    } else {
        [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    GHAPIEventV3 *event = [_events objectAtIndex:indexPath.row];
    
    [self tableView:tableView didSelectEvent:event atIndexPath:indexPath];
}

#pragma mark - Keyed Archiving

- (void)encodeWithCoder:(NSCoder *)encoder 
{
    [super encodeWithCoder:encoder];
    [encoder encodeObject:_events forKey:@"events"];
}

- (id)initWithCoder:(NSCoder *)decoder 
{
    if ((self = [super initWithCoder:decoder])) {
        _events = [decoder decodeObjectForKey:@"events"];
    }
    return self;
}

@end
