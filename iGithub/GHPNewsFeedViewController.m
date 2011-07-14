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
    [self downloadNewsFeed];
}

- (void)cacheNewsFeedHeight {
    [self.newsFeed.items enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        GHNewsFeedItem *item = obj;
        
        CGFloat height = UITableViewAutomaticDimension;
        
        if (item.payload.type == GHPayloadIssuesEvent) {
            // this is the height for an issue cell, we will display the whole issue
            GHIssuePayload *payload = (GHIssuePayload *)item.payload;
            
            if ([GHIssue isIssueAvailableForRepository:item.repository.fullName withNumber:payload.number]) {
                GHIssue *issue = [GHIssue issueFromDatabaseOnRepository:item.repository.fullName 
                                                             withNumber:payload.number];
                
                NSString *description = issue.title;
                height = [GHPDefaultNewsFeedTableViewCell heightWithContent:description];
            } else {
                height = [GHPDefaultNewsFeedTableViewCell heightWithContent:nil];
            }
        } else if (item.payload.type == GHPayloadPushEvent) {
            height = [GHPDefaultNewsFeedTableViewCell heightWithContent:[self descriptionForNewsFeedItem:item] ];
        } else if(item.payload.type == GHPayloadCommitCommentEvent) {
            height = GHPDefaultNewsFeedTableViewCellHeight;
        } else if(item.payload.type == GHPayloadFollowEvent) {
            height = GHPDefaultNewsFeedTableViewCellHeight;
        } else if(item.payload.type == GHPayloadWatchEvent) {
            height = GHPDefaultNewsFeedTableViewCellHeight;
        } else if(item.payload.type == GHPayloadCreateEvent) {
            height = GHPDefaultNewsFeedTableViewCellHeight;
        } else if(item.payload.type == GHPayloadForkEvent) {
            height = GHPDefaultNewsFeedTableViewCellHeight;
        } else if(item.payload.type == GHPayloadDeleteEvent) {
            height = GHPDefaultNewsFeedTableViewCellHeight;
        } else if(item.payload.type == GHPayloadGollumEvent) {
            height = GHPDefaultNewsFeedTableViewCellHeight;
        } else if(item.payload.type == GHPayloadGistEvent) {
            GHGistEventPayload *payload = (GHGistEventPayload *)item.payload;
            NSString *description = payload.descriptionGist ? payload.descriptionGist : payload.snippet;
            height = [GHPDefaultNewsFeedTableViewCell heightWithContent:description];
        } else if(item.payload.type == GHPayloadDownloadEvent) {
            GHDownloadEventPayload *payload = (GHDownloadEventPayload *)item.payload;
            NSString *description = [payload.URL lastPathComponent];
            height = [GHPDefaultNewsFeedTableViewCell heightWithContent:description];
        } else if(item.payload.type == GHPayloadPullRequestEvent) {
            height = [GHPDefaultNewsFeedTableViewCell heightWithContent:[self descriptionForNewsFeedItem:item] ];
        } else if(item.payload.type == GHPayloadMemberEvent) {
            height = GHPDefaultNewsFeedTableViewCellHeight;
        } else if(item.payload.type == GHPayloadIssueCommentEvent) {
            height = GHPDefaultNewsFeedTableViewCellHeight;
        } else if(item.payload.type == GHPayloadForkApplyEvent) {
            height = GHPDefaultNewsFeedTableViewCellHeight;
        } else if (item.payload.type == GHPayloadPublicEvent) {
            height = GHPDefaultNewsFeedTableViewCellHeight;
        } else {
#if DEBUG
            height = UITableViewAutomaticDimension;
#else
            height = 0.0f;
#endif
        }
        
        [self cacheHeight:height forRowAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0]];
    }];
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

- (NSString *)descriptionForNewsFeedItem:(GHNewsFeedItem *)item {
    NSString *description = nil;
    
    if (item.payload.type == GHPayloadPullRequestEvent) {
        GHPullRequestPayload *payload = (GHPullRequestPayload *)item.payload;
        
        if (payload.pullRequest) {
            NSString *additionsString = [NSString stringWithFormat:NSLocalizedString(@"%@ %@", @""), payload.pullRequest.additions, [payload.pullRequest.additions intValue] == 1 ? NSLocalizedString(@"addition", @"") : NSLocalizedString(@"additions", @"") ];
            NSString *deletionsString = [NSString stringWithFormat:NSLocalizedString(@"%@ %@", @""), payload.pullRequest.deletions, [payload.pullRequest.deletions intValue] == 1 ? NSLocalizedString(@"deletion", @"") : NSLocalizedString(@"deletions", @"") ];
            NSString *commitsString = [NSString stringWithFormat:NSLocalizedString(@"%@ %@", @""), payload.pullRequest.commits, [payload.pullRequest.commits intValue] == 1 ? NSLocalizedString(@"commit", @"") : NSLocalizedString(@"commits", @"") ];
            
            description = [NSString stringWithFormat:NSLocalizedString(@"%@ with %@ and %@", @""), commitsString, additionsString, deletionsString];
        }
    } else if (item.payload.type == GHPayloadPushEvent) {        
        GHPushPayload *payload = (GHPushPayload *)item.payload;
        
        NSMutableString *commitDescription = [NSMutableString string];
        
        [payload.commits enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            GHCommitMessage *commit = obj;
            
            if (idx == 0) {
                [commitDescription appendString:commit.message];
            } else if (idx == 1) {
                [commitDescription appendFormat:@"\n\n%@", commit.message];
                *stop = YES;
            }
        }];
        
        description = commitDescription;
    }
    
    return description;
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
        cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", 
                                item.actor, 
                                [NSString stringWithFormat:NSLocalizedString(@"%@ Issue %@", @""), 
                                 payload.action, 
                                 payload.number
                                 ]
                                ];
        cell.repositoryLabel.text = item.repository.fullName;
        
        GHIssue *issue = [GHIssue issueFromDatabaseOnRepository:item.repository.fullName withNumber:payload.number];
        
        if (issue) {            
            cell.detailTextLabel.text = issue.title;
        } else {
            [GHIssue issueOnRepository:[NSString stringWithFormat:@"%@/%@", item.repository.owner, item.repository.name] 
                            withNumber:payload.number 
                 useDatabaseIfPossible:YES 
                     completionHandler:^(GHIssue *issue, NSError *error, BOOL didDownload) {
                         if (error) {
                             [self handleError:error];
                         } else {
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
        
        GHPushPayload *payload = (GHPushPayload *)item.payload;
        
        NSUInteger numberOfCommits = [payload.commits count];
        cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@ pushed to %@ (%d)", @""), item.actor, payload.branch, numberOfCommits];
        cell.repositoryLabel.text = item.repository.fullName;
        cell.detailTextLabel.text = [self descriptionForNewsFeedItem:item];
        
        return cell;
    } else if (item.payload.type == GHPayloadCommitCommentEvent) {
        static NSString *CellIdentifier = @"GHPDefaultNewsFeedTableViewCell";
        GHPDefaultNewsFeedTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (!cell) {
            cell = [[[GHPDefaultNewsFeedTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        }
        [self setupDefaultTableViewCell:cell forRowAtIndexPath:indexPath];
        [self updateImageView:cell.imageView atIndexPath:indexPath withGravatarID:item.actorAttributes.gravatarID];
        
        cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@ commented on a commit", @""), item.actor];
        cell.repositoryLabel.text = item.repository.fullName;
        
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
        
        cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@ started following", @""), item.actor];
        cell.detailTextLabel.text = payload.target.login;
        
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
        
        GHWatchEventPayload *payload = (GHWatchEventPayload *)item.payload;
        
        cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@ %@ watching", @""), item.actor, payload.action];
        cell.repositoryLabel.text = item.repository.fullName;
        
        return cell;
    } else if (item.payload.type == GHPayloadCreateEvent) {
        static NSString *CellIdentifier = @"GHPDefaultNewsFeedTableViewCell";
        GHPDefaultNewsFeedTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (!cell) {
            cell = [[[GHPDefaultNewsFeedTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        }
        [self setupDefaultTableViewCell:cell forRowAtIndexPath:indexPath];
        [self updateImageView:cell.imageView atIndexPath:indexPath withGravatarID:item.actorAttributes.gravatarID];
        
        GHCreateEventPayload *payload = (GHCreateEventPayload *)item.payload;
        
        if (payload.objectType == GHCreateEventObjectRepository) {
            cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@ created repository", @""), item.actor];
            cell.repositoryLabel.text = payload.ref;
        } else if (payload.objectType == GHCreateEventObjectBranch) {
            cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@ created branch %@", @""), item.actor, payload.ref];
            cell.repositoryLabel.text = item.repository.fullName;
        } else if (payload.objectType == GHCreateEventObjectTag) {
            cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@ created tag %@", @""), item.actor, payload.ref];
            cell.repositoryLabel.text = item.repository.fullName;
        } else {
            cell.textLabel.text = @"__UNKNWON_CREATE_EVENT__";
            cell.repositoryLabel.text = nil;
        }
        
        return cell;
    } else if (item.payload.type == GHPayloadForkEvent) {
        static NSString *CellIdentifier = @"GHPDefaultNewsFeedTableViewCell";
        GHPDefaultNewsFeedTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (!cell) {
            cell = [[[GHPDefaultNewsFeedTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        }
        [self setupDefaultTableViewCell:cell forRowAtIndexPath:indexPath];
        [self updateImageView:cell.imageView atIndexPath:indexPath withGravatarID:item.actorAttributes.gravatarID];
        
        cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@ forked repository", @""), item.actor];
        cell.repositoryLabel.text = item.repository.fullName;
        
        return cell;
    } else if (item.payload.type == GHPayloadDeleteEvent) {
        static NSString *CellIdentifier = @"GHPDefaultNewsFeedTableViewCell";
        GHPDefaultNewsFeedTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (!cell) {
            cell = [[[GHPDefaultNewsFeedTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        }
        [self setupDefaultTableViewCell:cell forRowAtIndexPath:indexPath];
        [self updateImageView:cell.imageView atIndexPath:indexPath withGravatarID:item.actorAttributes.gravatarID];
        
        GHDeleteEventPayload *payload = (GHDeleteEventPayload *)item.payload;
        
        cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@ deleted %@ %@", @""), item.actor, payload.refType, payload.ref];
        
        NSString *repoURL = item.repository.URL;
        NSArray *components = [repoURL componentsSeparatedByString:@"/"];
        NSUInteger count = [components count];
        if (count > 1) {
            cell.repositoryLabel.text = [NSString stringWithFormat:@"%@/%@", [components objectAtIndex:count-2], [components lastObject]];
        } else {
            cell.repositoryLabel.text = item.repository.name;
        }
        
        return cell;
    } else if (item.payload.type == GHPayloadGollumEvent) {
        static NSString *CellIdentifier = @"GHPDefaultNewsFeedTableViewCell";
        GHPDefaultNewsFeedTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (!cell) {
            cell = [[[GHPDefaultNewsFeedTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        }
        [self setupDefaultTableViewCell:cell forRowAtIndexPath:indexPath];
        [self updateImageView:cell.imageView atIndexPath:indexPath withGravatarID:item.actorAttributes.gravatarID];
        
        GHGollumEventPayload *payload = (GHGollumEventPayload *)item.payload;
        
        cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@ %@ %@ in wiki", @""), item.actor, payload.action, payload.pageName];
        cell.repositoryLabel.text = item.repository.fullName;
        
        return cell;
    } else if (item.payload.type == GHPayloadGistEvent) {
        static NSString *CellIdentifier = @"GHPDefaultNewsFeedTableViewCell";
        GHPDefaultNewsFeedTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (!cell) {
            cell = [[[GHPDefaultNewsFeedTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        }
        [self setupDefaultTableViewCell:cell forRowAtIndexPath:indexPath];
        [self updateImageView:cell.imageView atIndexPath:indexPath withGravatarID:item.actorAttributes.gravatarID];
        
        GHGistEventPayload *payload = (GHGistEventPayload *)item.payload;
        
        NSString *action = payload.action;
        if ([action hasSuffix:@"e"]) {
            action = [action stringByAppendingString:@"d"];
        } else {
            action = [action stringByAppendingString:@"ed"];
        }
        
        cell.repositoryLabel.text = nil;
        cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@ %@ %@", @""), item.actor, action, payload.name];
        cell.detailTextLabel.text = payload.descriptionGist ? payload.descriptionGist : payload.snippet;
        
        return cell;
    } else if (item.payload.type == GHPayloadDownloadEvent) {
        static NSString *CellIdentifier = @"GHPDefaultNewsFeedTableViewCell";
        GHPDefaultNewsFeedTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (!cell) {
            cell = [[[GHPDefaultNewsFeedTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        }
        [self setupDefaultTableViewCell:cell forRowAtIndexPath:indexPath];
        [self updateImageView:cell.imageView atIndexPath:indexPath withGravatarID:item.actorAttributes.gravatarID];
        
        GHDownloadEventPayload *payload = (GHDownloadEventPayload *)item.payload;
        
        cell.repositoryLabel.text = item.repository.fullName;
        cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@ uploaded a file", @""), item.actor];
        cell.detailTextLabel.text = [payload.URL lastPathComponent];
        
        return cell;
    } else if (item.payload.type == GHPayloadPullRequestEvent) {
        static NSString *CellIdentifier = @"GHPDefaultNewsFeedTableViewCell";
        GHPDefaultNewsFeedTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (!cell) {
            cell = [[[GHPDefaultNewsFeedTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        }
        [self setupDefaultTableViewCell:cell forRowAtIndexPath:indexPath];
        [self updateImageView:cell.imageView atIndexPath:indexPath withGravatarID:item.actorAttributes.gravatarID];
        
        GHPullRequestPayload *payload = (GHPullRequestPayload *)item.payload;
        
        cell.repositoryLabel.text = item.repository.fullName;
        cell.detailTextLabel.text = [self descriptionForNewsFeedItem:item];
        cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@ %@ pull request %@", @""), item.actor, payload.action, payload.number];
        
        return cell;
    } else if (item.payload.type == GHPayloadMemberEvent) {
        static NSString *CellIdentifier = @"GHPDefaultNewsFeedTableViewCell";
        GHPDefaultNewsFeedTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (!cell) {
            cell = [[[GHPDefaultNewsFeedTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        }
        [self setupDefaultTableViewCell:cell forRowAtIndexPath:indexPath];
        [self updateImageView:cell.imageView atIndexPath:indexPath withGravatarID:item.actorAttributes.gravatarID];
        
        GHMemberEventPayload *payload = (GHMemberEventPayload *)item.payload;
        
        cell.repositoryLabel.text = item.repository.fullName;
        cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@ %@ %@", @""), item.actor, payload.action, payload.member.login];
        
        return cell;
    } else if (item.payload.type == GHPayloadIssueCommentEvent) {
        static NSString *CellIdentifier = @"GHPDefaultNewsFeedTableViewCell";
        GHPDefaultNewsFeedTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (!cell) {
            cell = [[[GHPDefaultNewsFeedTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        }
        [self setupDefaultTableViewCell:cell forRowAtIndexPath:indexPath];
        [self updateImageView:cell.imageView atIndexPath:indexPath withGravatarID:item.actorAttributes.gravatarID];
        
        GHIssuesCommentPayload *payload = (GHIssuesCommentPayload *)item.payload;
        
        cell.repositoryLabel.text = item.repository.fullName;
        cell.textLabel.text = item.actor;
        cell.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedString(@"commented on Issue %@", @""), payload.issueID];
        
        return cell;
    } else if (item.payload.type == GHPayloadForkApplyEvent) {
        static NSString *CellIdentifier = @"GHPDefaultNewsFeedTableViewCell";
        GHPDefaultNewsFeedTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (!cell) {
            cell = [[[GHPDefaultNewsFeedTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        }
        [self setupDefaultTableViewCell:cell forRowAtIndexPath:indexPath];
        [self updateImageView:cell.imageView atIndexPath:indexPath withGravatarID:item.actorAttributes.gravatarID];
        
        GHForkApplyEventPayload *payload = (GHForkApplyEventPayload *)item.payload;
        
        cell.repositoryLabel.text = item.repository.fullName;
        cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@ applied fork commits", @""), item.actor];
        cell.detailTextLabel.text = payload.commit;
        
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
        cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@ open sourced", @""), item.actor];
        
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

@end
