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

@synthesize newsFeed=_newsFeed;

#pragma mark - setters and getters

- (void)setNewsFeed:(GHNewsFeed *)newsFeed {
    if (newsFeed != _newsFeed) {
        [_newsFeed release];
        _newsFeed = [newsFeed retain];
        [self cacheNewsFeedHeight];
        
        self.isDownloadingEssentialData = NO;
        
        if (self.isViewLoaded) {
            [self.tableView reloadData];
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

- (void)cacheNewsFeedHeight {
    [self.newsFeed.items enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        GHNewsFeedItem *item = obj;
        CGFloat height = [GHPDefaultNewsFeedTableViewCell heightWithContent:[self descriptionForNewsFeedItem:item]];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:idx inSection:0];
        
        [self cacheHeight:height forRowAtIndexPath:indexPath];
    }];
}

- (NSString *)descriptionForNewsFeedItem:(GHNewsFeedItem *)item {
    NSString *description = nil;
    
    if (item.payload.type == GHPayloadIssuesEvent) {
        // this is the height for an issue cell, we will display the whole issue
        GHIssuePayload *payload = (GHIssuePayload *)item.payload;
        
        if ([GHIssue isIssueAvailableForRepository:item.repository.fullName withNumber:payload.number]) {
            GHIssue *issue = [GHIssue issueFromDatabaseOnRepository:item.repository.fullName 
                                                         withNumber:payload.number];
            
            description = [NSString stringWithFormat:NSLocalizedString(@"%@ Issue %@:\n\n%@", @""), payload.action, payload.number, issue.title];
        }
    } else if (item.payload.type == GHPayloadPushEvent) {
        GHPushPayload *payload = (GHPushPayload *)item.payload;
        // this is a commit / push message, we will display max 2 commits
        description = [NSString stringWithFormat:NSLocalizedString(@"pushed to %@ (%d)\n\n%@", @""), payload.branch, payload.commits.count, payload.previewString];
    } else if(item.payload.type == GHPayloadCommitCommentEvent) {
        description = NSLocalizedString(@"commented on a commit", @"");
    } else if(item.payload.type == GHPayloadFollowEvent) {
        GHFollowEventPayload *payload = (GHFollowEventPayload *)item.payload;
        description = payload.target.login;
    } else if(item.payload.type == GHPayloadWatchEvent) {
        GHWatchEventPayload *payload = (GHWatchEventPayload *)item.payload;
        description = [NSString stringWithFormat:NSLocalizedString(@"%@ watching", @""), payload.action];
    } else if(item.payload.type == GHPayloadCreateEvent) {
        GHCreateEventPayload *payload = (GHCreateEventPayload *)item.payload;
        if (payload.objectType == GHCreateEventObjectRepository) {
            description = NSLocalizedString(@"created repository", @"");
        } else if (payload.objectType == GHCreateEventObjectBranch) {
            description = [NSString stringWithFormat:NSLocalizedString(@"created branch %@", @""), payload.ref];
        } else if (payload.objectType == GHCreateEventObjectTag) {
            description = [NSString stringWithFormat:NSLocalizedString(@"created tag %@", @""), payload.ref];
        } else {
            description = @"__UNKNWON_CREATE_EVENT__";
        }
    } else if(item.payload.type == GHPayloadForkEvent) {
        description = NSLocalizedString(@"forked repository", @"");
    } else if(item.payload.type == GHPayloadDeleteEvent) {
        GHDeleteEventPayload *payload = (GHDeleteEventPayload *)item.payload;
        description = [NSString stringWithFormat:NSLocalizedString(@"deleted %@ %@", @""), payload.refType, payload.ref];
    } else if(item.payload.type == GHPayloadGollumEvent) {
        GHGollumEventPayload *payload = (GHGollumEventPayload *)item.payload;
        description = [NSString stringWithFormat:NSLocalizedString(@"%@ %@ in wiki", @""), payload.action, payload.pageName];
    } else if(item.payload.type == GHPayloadGistEvent) {
        GHGistEventPayload *payload = (GHGistEventPayload *)item.payload;
        
        NSString *action = payload.action;
        if ([action hasSuffix:@"e"]) {
            action = [action stringByAppendingString:@"d"];
        } else {
            action = [action stringByAppendingString:@"ed"];
        }
        
        description = [NSString stringWithFormat:@"%@ %@:\n\n%@", action, payload.name, payload.descriptionGist ? payload.descriptionGist : payload.snippet];
    } else if(item.payload.type == GHPayloadDownloadEvent) {
        // this is the height for an issue cell, we will display the whole issue
        GHDownloadEventPayload *payload = (GHDownloadEventPayload *)item.payload;
        description = [NSString stringWithFormat:NSLocalizedString(@"uploaded file:%@", @""), item.actor, [payload.URL lastPathComponent]];
    } else if(item.payload.type == GHPayloadPullRequestEvent) {
        // this is the height for an issue cell, we will display the whole issue
        GHPullRequestPayload *payload = (GHPullRequestPayload *)item.payload;
        
        if (payload.pullRequest) {
            NSString *additionsString = [NSString stringWithFormat:NSLocalizedString(@"%@ %@", @""), payload.pullRequest.additions, [payload.pullRequest.additions intValue] == 1 ? NSLocalizedString(@"addition", @"") : NSLocalizedString(@"additions", @"") ];
            NSString *deletionsString = [NSString stringWithFormat:NSLocalizedString(@"%@ %@", @""), payload.pullRequest.deletions, [payload.pullRequest.deletions intValue] == 1 ? NSLocalizedString(@"deletion", @"") : NSLocalizedString(@"deletions", @"") ];
            NSString *commitsString = [NSString stringWithFormat:NSLocalizedString(@"%@ %@", @""), payload.pullRequest.commits, [payload.pullRequest.commits intValue] == 1 ? NSLocalizedString(@"commit", @"") : NSLocalizedString(@"commits", @"") ];
            
            description = [NSString stringWithFormat:NSLocalizedString(@"%@ with %@ and %@", @""), commitsString, additionsString, deletionsString];
        }
        description = [NSString stringWithFormat:NSLocalizedString(@"%@ pull request %@:\n\n%@", @""), payload.action, payload.number, description];
    } else if(item.payload.type == GHPayloadMemberEvent) {
        GHMemberEventPayload *payload = (GHMemberEventPayload *)item.payload;
        
        description = [NSString stringWithFormat:NSLocalizedString(@"%@ %@", @""), payload.action, payload.member.login];
    } else if(item.payload.type == GHPayloadIssueCommentEvent) {
        GHIssuesCommentPayload *payload = (GHIssuesCommentPayload *)item.payload;
        description = [NSString stringWithFormat:NSLocalizedString(@"commented on Issue %@", @""), payload.issueID];
    } else if(item.payload.type == GHPayloadForkApplyEvent) {
        GHForkApplyEventPayload *payload = (GHForkApplyEventPayload *)item.payload;
        description = [NSString stringWithFormat:NSLocalizedString(@"applied fork commits:\n\n%@", @""), payload.commit];
    } else if (item.payload.type == GHPayloadPublicEvent) {
        description = NSLocalizedString(@"open sourced", @"");
    }
    
    return description;
}

#pragma mark - Initialization

- (id)init {
    if ((self = [super initWithStyle:UITableViewStyleGrouped])) {
        // Custom initialization
        self.isDownloadingEssentialData = YES;
        [self performSelector:@selector(downloadNewsFeed) withObject:nil afterDelay:0.01];
    }
    return self;
}

#pragma mark - Memory management

- (void)dealloc {
    [_newsFeed release];
    
    [super dealloc];
}

#pragma mark - View lifecycle

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
	return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.newsFeed.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GHNewsFeedItem *item = [self.newsFeed.items objectAtIndex:indexPath.row];
    
    if (item.payload.type == GHPayloadIssuesEvent) {
        // we will display an issue
        static NSString *CellIdentifier = @"GHPDefaultNewsFeedTableViewCell";
        GHPDefaultNewsFeedTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (!cell) {
            cell = [[[GHPDefaultNewsFeedTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        }
        [self setupDefaultTableViewCell:cell forRowAtIndexPath:indexPath];
        [self updateImageView:cell.imageView atIndexPath:indexPath withGravatarID:item.actorAttributes.gravatarID];
        
        GHIssuePayload *payload = (GHIssuePayload *)item.payload;
        cell.textLabel.text = item.actor;
        cell.repositoryLabel.text = item.repository.fullName;
        cell.timeLabel.text = item.creationDate.prettyShortTimeIntervalSinceNow;
        
        GHIssue *issue = [GHIssue issueFromDatabaseOnRepository:item.repository.fullName withNumber:payload.number];
        
        if (issue) {            
            cell.detailTextLabel.text = [self descriptionForNewsFeedItem:item];
        } else {
            [GHIssue issueOnRepository:[NSString stringWithFormat:@"%@/%@", item.repository.owner, item.repository.name] 
                            withNumber:payload.number 
                 useDatabaseIfPossible:YES 
                     completionHandler:^(GHIssue *issue, NSError *error, BOOL didDownload) {
                         if (error) {
                             [self handleError:error];
                         } else {
                             [self cacheNewsFeedHeight];
                             if ([tableView containsIndexPath:indexPath]) {
                                 [tableView reloadRowAtIndexPath:indexPath withRowAnimation:UITableViewRowAnimationNone];
                             }
                         }
                     }];
        }
        
        return cell;
    } else if (item.payload.type == GHPayloadPushEvent) {
        static NSString *CellIdentifier = @"GHPDefaultNewsFeedTableViewCell";
        GHPDefaultNewsFeedTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (!cell) {
            cell = [[[GHPDefaultNewsFeedTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        }
        [self setupDefaultTableViewCell:cell forRowAtIndexPath:indexPath];
        [self updateImageView:cell.imageView atIndexPath:indexPath withGravatarID:item.actorAttributes.gravatarID];
        
        cell.textLabel.text = item.actor;
        cell.repositoryLabel.text = item.repository.fullName;
        cell.detailTextLabel.text = [self descriptionForNewsFeedItem:item];
        cell.timeLabel.text = item.creationDate.prettyShortTimeIntervalSinceNow;
        
        return cell;
    } else if (item.payload.type == GHPayloadCommitCommentEvent) {
        static NSString *CellIdentifier = @"GHPDefaultNewsFeedTableViewCell";
        GHPDefaultNewsFeedTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (!cell) {
            cell = [[[GHPDefaultNewsFeedTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        }
        [self setupDefaultTableViewCell:cell forRowAtIndexPath:indexPath];
        [self updateImageView:cell.imageView atIndexPath:indexPath withGravatarID:item.actorAttributes.gravatarID];
        
        cell.textLabel.text = item.actor;
        cell.detailTextLabel.text = [self descriptionForNewsFeedItem:item];
        cell.repositoryLabel.text = item.repository.fullName;
        cell.timeLabel.text = item.creationDate.prettyShortTimeIntervalSinceNow;
        
        return cell;
    } else if (item.payload.type == GHPayloadFollowEvent) {
        static NSString *CellIdentifier = @"GHPNewsFeedSecondUserTableViewCell";
        GHPNewsFeedSecondUserTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (!cell) {
            cell = [[[GHPNewsFeedSecondUserTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        }
        [self setupDefaultTableViewCell:cell forRowAtIndexPath:indexPath];
        [self updateImageView:cell.imageView atIndexPath:indexPath withGravatarID:item.actorAttributes.gravatarID];
        
        GHFollowEventPayload *payload = (GHFollowEventPayload *)item.payload;
        
        cell.textLabel.text = item.actor;
        cell.detailTextLabel.text = [self descriptionForNewsFeedItem:item];
        cell.timeLabel.text = item.creationDate.prettyShortTimeIntervalSinceNow;
        
        [self updateImageView:cell.secondImageView atIndexPath:indexPath withGravatarID:payload.target.gravatarID];
        
        return cell;
    } else if (item.payload.type == GHPayloadWatchEvent) {
        static NSString *CellIdentifier = @"GHPDefaultNewsFeedTableViewCell";
        GHPDefaultNewsFeedTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (!cell) {
            cell = [[[GHPDefaultNewsFeedTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        }
        [self setupDefaultTableViewCell:cell forRowAtIndexPath:indexPath];
        [self updateImageView:cell.imageView atIndexPath:indexPath withGravatarID:item.actorAttributes.gravatarID];
        
        cell.textLabel.text = item.actor;
        cell.detailTextLabel.text = [self descriptionForNewsFeedItem:item];
        cell.repositoryLabel.text = item.repository.fullName;
        cell.timeLabel.text = item.creationDate.prettyShortTimeIntervalSinceNow;
        
        return cell;
    } else if (item.payload.type == GHPayloadCreateEvent) {
        static NSString *CellIdentifier = @"GHPDefaultNewsFeedTableViewCell";
        GHPDefaultNewsFeedTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (!cell) {
            cell = [[[GHPDefaultNewsFeedTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        }
        [self setupDefaultTableViewCell:cell forRowAtIndexPath:indexPath];
        [self updateImageView:cell.imageView atIndexPath:indexPath withGravatarID:item.actorAttributes.gravatarID];
        
        cell.timeLabel.text = item.creationDate.prettyShortTimeIntervalSinceNow;
        cell.textLabel.text = item.actor;
        cell.detailTextLabel.text = [self descriptionForNewsFeedItem:item];
        cell.repositoryLabel.text = item.repository.fullName;
        
        return cell;
    } else if (item.payload.type == GHPayloadForkEvent) {
        static NSString *CellIdentifier = @"GHPDefaultNewsFeedTableViewCell";
        GHPDefaultNewsFeedTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (!cell) {
            cell = [[[GHPDefaultNewsFeedTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        }
        [self setupDefaultTableViewCell:cell forRowAtIndexPath:indexPath];
        [self updateImageView:cell.imageView atIndexPath:indexPath withGravatarID:item.actorAttributes.gravatarID];
        
        cell.textLabel.text = item.actor;
        cell.detailTextLabel.text = [self descriptionForNewsFeedItem:item];
        cell.repositoryLabel.text = item.repository.fullName;
        cell.timeLabel.text = item.creationDate.prettyShortTimeIntervalSinceNow;
        
        return cell;
    } else if (item.payload.type == GHPayloadDeleteEvent) {
        static NSString *CellIdentifier = @"GHPDefaultNewsFeedTableViewCell";
        GHPDefaultNewsFeedTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (!cell) {
            cell = [[[GHPDefaultNewsFeedTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        }
        [self setupDefaultTableViewCell:cell forRowAtIndexPath:indexPath];
        [self updateImageView:cell.imageView atIndexPath:indexPath withGravatarID:item.actorAttributes.gravatarID];
        
        cell.textLabel.text = item.actor;
        cell.detailTextLabel.text = [self descriptionForNewsFeedItem:item];
        NSString *repoURL = item.repository.URL;
        NSArray *components = [repoURL componentsSeparatedByString:@"/"];
        NSUInteger count = [components count];
        if (count > 1) {
            cell.repositoryLabel.text = [NSString stringWithFormat:@"%@/%@", [components objectAtIndex:count-2], [components lastObject]];
        } else {
            cell.repositoryLabel.text = item.repository.name;
        }
        cell.timeLabel.text = item.creationDate.prettyShortTimeIntervalSinceNow;
        
        return cell;
    } else if (item.payload.type == GHPayloadGollumEvent) {
        static NSString *CellIdentifier = @"GHPDefaultNewsFeedTableViewCell";
        GHPDefaultNewsFeedTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (!cell) {
            cell = [[[GHPDefaultNewsFeedTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        }
        [self setupDefaultTableViewCell:cell forRowAtIndexPath:indexPath];
        [self updateImageView:cell.imageView atIndexPath:indexPath withGravatarID:item.actorAttributes.gravatarID];
        
        cell.textLabel.text = item.actor;
        cell.detailTextLabel.text = [self descriptionForNewsFeedItem:item];
        cell.repositoryLabel.text = item.repository.fullName;
        cell.timeLabel.text = item.creationDate.prettyShortTimeIntervalSinceNow;
        
        return cell;
    } else if (item.payload.type == GHPayloadGistEvent) {
        static NSString *CellIdentifier = @"GHPDefaultNewsFeedTableViewCell";
        GHPDefaultNewsFeedTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (!cell) {
            cell = [[[GHPDefaultNewsFeedTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        }
        [self setupDefaultTableViewCell:cell forRowAtIndexPath:indexPath];
        [self updateImageView:cell.imageView atIndexPath:indexPath withGravatarID:item.actorAttributes.gravatarID];
        
        cell.repositoryLabel.text = nil;
        cell.textLabel.text = item.actor;
        cell.detailTextLabel.text = [self descriptionForNewsFeedItem:item];
        cell.timeLabel.text = item.creationDate.prettyShortTimeIntervalSinceNow;
        
        return cell;
    } else if (item.payload.type == GHPayloadDownloadEvent) {
        static NSString *CellIdentifier = @"GHPDefaultNewsFeedTableViewCell";
        GHPDefaultNewsFeedTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (!cell) {
            cell = [[[GHPDefaultNewsFeedTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        }
        [self setupDefaultTableViewCell:cell forRowAtIndexPath:indexPath];
        [self updateImageView:cell.imageView atIndexPath:indexPath withGravatarID:item.actorAttributes.gravatarID];
        
        cell.repositoryLabel.text = item.repository.fullName;
        cell.textLabel.text = item.actor;
        cell.detailTextLabel.text = [self descriptionForNewsFeedItem:item];
        cell.timeLabel.text = item.creationDate.prettyShortTimeIntervalSinceNow;
        
        return cell;
    } else if (item.payload.type == GHPayloadPullRequestEvent) {
        static NSString *CellIdentifier = @"GHPDefaultNewsFeedTableViewCell";
        GHPDefaultNewsFeedTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (!cell) {
            cell = [[[GHPDefaultNewsFeedTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        }
        [self setupDefaultTableViewCell:cell forRowAtIndexPath:indexPath];
        [self updateImageView:cell.imageView atIndexPath:indexPath withGravatarID:item.actorAttributes.gravatarID];
        
        cell.repositoryLabel.text = item.repository.fullName;
        cell.textLabel.text = item.actor;
        cell.detailTextLabel.text = [self descriptionForNewsFeedItem:item];
        cell.timeLabel.text = item.creationDate.prettyShortTimeIntervalSinceNow;
        
        return cell;
    } else if (item.payload.type == GHPayloadMemberEvent) {
        static NSString *CellIdentifier = @"GHPDefaultNewsFeedTableViewCell";
        GHPDefaultNewsFeedTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (!cell) {
            cell = [[[GHPDefaultNewsFeedTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        }
        [self setupDefaultTableViewCell:cell forRowAtIndexPath:indexPath];
        [self updateImageView:cell.imageView atIndexPath:indexPath withGravatarID:item.actorAttributes.gravatarID];
        
        cell.repositoryLabel.text = item.repository.fullName;
        cell.textLabel.text = item.actor;
        cell.detailTextLabel.text = [self descriptionForNewsFeedItem:item];
        cell.timeLabel.text = item.creationDate.prettyShortTimeIntervalSinceNow;
        
        return cell;
    } else if (item.payload.type == GHPayloadIssueCommentEvent) {
        static NSString *CellIdentifier = @"GHPDefaultNewsFeedTableViewCell";
        GHPDefaultNewsFeedTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (!cell) {
            cell = [[[GHPDefaultNewsFeedTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        }
        [self setupDefaultTableViewCell:cell forRowAtIndexPath:indexPath];
        [self updateImageView:cell.imageView atIndexPath:indexPath withGravatarID:item.actorAttributes.gravatarID];
        
        cell.repositoryLabel.text = item.repository.fullName;
        cell.textLabel.text = item.actor;
        cell.detailTextLabel.text = [self descriptionForNewsFeedItem:item];
        cell.timeLabel.text = item.creationDate.prettyShortTimeIntervalSinceNow;
        
        return cell;
    } else if (item.payload.type == GHPayloadForkApplyEvent) {
        static NSString *CellIdentifier = @"GHPDefaultNewsFeedTableViewCell";
        GHPDefaultNewsFeedTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (!cell) {
            cell = [[[GHPDefaultNewsFeedTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        }
        [self setupDefaultTableViewCell:cell forRowAtIndexPath:indexPath];
        [self updateImageView:cell.imageView atIndexPath:indexPath withGravatarID:item.actorAttributes.gravatarID];
        
        cell.repositoryLabel.text = item.repository.fullName;
        cell.textLabel.text = item.actor;
        cell.detailTextLabel.text = [self descriptionForNewsFeedItem:item];
        cell.timeLabel.text = item.creationDate.prettyShortTimeIntervalSinceNow;
        
        return cell;
    } else if (item.payload.type == GHPayloadPublicEvent) {
        static NSString *CellIdentifier = @"GHPDefaultNewsFeedTableViewCell";
        GHPDefaultNewsFeedTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (!cell) {
            cell = [[[GHPDefaultNewsFeedTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        }
        [self setupDefaultTableViewCell:cell forRowAtIndexPath:indexPath];
        [self updateImageView:cell.imageView atIndexPath:indexPath withGravatarID:item.actorAttributes.gravatarID];
        
        cell.repositoryLabel.text = item.repository.fullName;
        cell.textLabel.text = item.actor;
        cell.detailTextLabel.text = [self descriptionForNewsFeedItem:item];
        cell.timeLabel.text = item.creationDate.prettyShortTimeIntervalSinceNow;
        
        return cell;
    }
    
    return [self dummyCellWithText:item.type];
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self cachedHeightForRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    GHNewsFeedItem *item = [self.newsFeed.items objectAtIndex:indexPath.row];
    
    UIViewController *viewController = nil;
    
    if (item.payload.type == GHPayloadIssuesEvent) {
        GHIssuePayload *payload = (GHIssuePayload *)item.payload;
        viewController = [[[GHPIssueViewController alloc] initWithIssueNumber:payload.number onRepository:item.repository.fullName] autorelease];
    } else if (item.payload.type == GHPayloadPullRequestEvent) {
        GHPullRequestPayload *payload = (GHPullRequestPayload *)item.payload;
        viewController = [[[GHPIssueViewController alloc] initWithIssueNumber:payload.number onRepository:item.repository.fullName] autorelease];
    } else if (item.payload.type == GHPayloadPushEvent) {
        GHPushPayload *payload = (GHPushPayload *)item.payload;
        if (payload.commits.count == 1) {
            viewController = [[[GHPCommitViewController alloc] initWithRepository:item.repository.fullName commitID:payload.head] autorelease];
        } else {
            viewController = [[[GHPCommitsViewController alloc] initWithRepository:item.repository.fullName pushPayload:payload] autorelease];
        }
    } else if (item.payload.type == GHPayloadWatchEvent) {
        viewController = [[[GHPRepositoryViewController alloc] initWithRepositoryString:item.repository.fullName] autorelease];
    } else if (item.payload.type == GHPayloadFollowEvent) {
        GHFollowEventPayload *payload = (GHFollowEventPayload *)item.payload;
        viewController = [[[GHPUserViewController alloc] initWithUsername:payload.target.login] autorelease];
    } else if (item.payload.type == GHPayloadCreateEvent) {
        viewController = [[[GHPRepositoryViewController alloc] initWithRepositoryString:item.repository.fullName] autorelease];
    } else if (item.payload.type == GHPayloadIssueCommentEvent) {
        GHIssuesCommentPayload *payload = (GHIssuesCommentPayload *)item.payload;
        viewController = [[[GHPIssueViewController alloc] initWithIssueNumber:payload.issueID onRepository:item.repository.fullName] autorelease];
    } else if (item.payload.type == GHPayloadPublicEvent) {
        viewController = [[[GHPRepositoryViewController alloc] initWithRepositoryString:item.repository.fullName] autorelease];
    } else if (item.payload.type == GHPayloadCommitCommentEvent) {
        viewController = [[[GHPRepositoryViewController alloc] initWithRepositoryString:item.repository.fullName] autorelease];
    } else if (item.payload.type == GHPayloadDeleteEvent) {
        viewController = [[[GHPRepositoryViewController alloc] initWithRepositoryString:item.repository.fullName] autorelease];
    } else if (item.payload.type == GHPayloadDownloadEvent) {
        viewController = [[[GHPRepositoryViewController alloc] initWithRepositoryString:item.repository.fullName] autorelease];
    } else if (item.payload.type == GHPayloadForkApplyEvent) {
        viewController = [[[GHPRepositoryViewController alloc] initWithRepositoryString:item.repository.fullName] autorelease];
    } else if (item.payload.type == GHPayloadGollumEvent) {
        viewController = [[[GHPRepositoryViewController alloc] initWithRepositoryString:item.repository.fullName] autorelease];
    } else if (item.payload.type == GHPayloadForkEvent) {
        viewController = [[[GHPRepositoryViewController alloc] initWithRepositoryString:item.repository.fullName] autorelease];
    } else if (item.payload.type == GHPayloadMemberEvent) {
        GHMemberEventPayload *payload = (GHMemberEventPayload *)item.payload;
        viewController = [[[GHPUserViewController alloc] initWithUsername:payload.member.login] autorelease];
    } else if (item.payload.type == GHPayloadGistEvent) {
        GHGistEventPayload *payload = (GHGistEventPayload *)item.payload;
        viewController = [[[GHPGistViewController alloc] initWithGistID:payload.gistID] autorelease];
    }
    
    if (viewController) {
        [self.advancedNavigationController pushViewController:viewController afterViewController:self animated:YES];
    } else {
        [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
}

#pragma mark - Keyed Archiving

- (void)encodeWithCoder:(NSCoder *)encoder {
    [super encodeWithCoder:encoder];
    [encoder encodeObject:_newsFeed forKey:@"newsFeed"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super initWithCoder:decoder])) {
        _newsFeed = [[decoder decodeObjectForKey:@"newsFeed"] retain];
        [self downloadNewsFeed];
    }
    return self;
}

@end
