//
//  GHNewsFeedViewController.m
//  iGithub
//
//  Created by Oliver Letterer on 30.03.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHNewsFeedViewController.h"
#import "GithubAPI.h"
#import "GHSettingsHelper.h"
#import "GHDescriptionTableViewCell.h"
#import "GHFollowEventTableViewCell.h"
#import "GHIssueViewController.h"
#import "GHPushPayloadViewController.h"
#import "GHRepositoryViewController.h"
#import "GHUserViewController.h"
#import "GHGistViewController.h"

@implementation GHNewsFeedViewController

@synthesize newsFeed=_newsFeed;

#pragma mark - setters and getters

- (void)setNewsFeed:(GHNewsFeed *)newsFeed {
    if (newsFeed != _newsFeed) {
        _newsFeed = newsFeed;
        [self cacheHeightForTableView];
        if (self.isViewLoaded) {
            [self.tableView reloadData];
            [self scrollViewDidEndDecelerating:self.tableView];
        }
    }
}

#pragma mark - Initialization

- (id)init {
    if ((self = [super initWithStyle:UITableViewStylePlain])) {
        // Custom initialization
        self.pullToReleaseEnabled = YES;
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

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.newsFeed.items count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    GHNewsFeedItem *item = [self.newsFeed.items objectAtIndex:indexPath.row];
    
    if (item.payload.type == GHPayloadIssuesEvent) {
        // we will display an issue
        static NSString *CellIdentifier = @"GHFeedItemWithDescriptionTableViewCell";
        GHDescriptionTableViewCell *cell = (GHDescriptionTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (!cell) {
            cell = [[GHDescriptionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        GHIssuePayload *payload = (GHIssuePayload *)item.payload;
        
        [self updateImageView:cell.imageView atIndexPath:indexPath withGravatarID:item.actorAttributes.gravatarID];
        
        cell.textLabel.text = item.actor;
        cell.detailTextLabel.text = item.repository.fullName;
        cell.timeLabel.text = item.creationDate.prettyShortTimeIntervalSinceNow;
        
        GHIssue *issue = [GHIssue issueFromDatabaseOnRepository:item.repository.fullName withNumber:payload.number];
        
        if (issue) {
            cell.descriptionLabel.text = [self descriptionForNewsFeedItem:item];
        } else {
            [GHIssue issueOnRepository:[NSString stringWithFormat:@"%@/%@", item.repository.owner, item.repository.name] 
                            withNumber:payload.number 
                 useDatabaseIfPossible:YES 
                     completionHandler:^(GHIssue *issue, NSError *error, BOOL didDownload) {
                         if (error) {
                             [self handleError:error];
                         } else {
                             CGFloat height = [GHDescriptionTableViewCell heightWithContent:[self descriptionForNewsFeedItem:item]];
                             
                             [self cacheHeight:height forRowAtIndexPath:indexPath];
                             if ([tableView containsIndexPath:indexPath]) {
                                 [tableView reloadRowAtIndexPath:indexPath withRowAnimation:UITableViewRowAnimationNone];
                             }
                         }
                     }];
        }
                
        return cell;
    } else if (item.payload.type == GHPayloadPushEvent) {
        // tableView is asking for a push item
        
        static NSString *CellIdentifier = @"GHFeedItemWithDescriptionTableViewCell";
        GHDescriptionTableViewCell *cell = (GHDescriptionTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (!cell) {
            cell = [[GHDescriptionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        [self updateImageView:cell.imageView atIndexPath:indexPath withGravatarID:item.actorAttributes.gravatarID];
        cell.detailTextLabel.text = item.repository.fullName;
        cell.textLabel.text = item.actor;
        cell.descriptionLabel.text = [self descriptionForNewsFeedItem:item];
        cell.timeLabel.text = item.creationDate.prettyShortTimeIntervalSinceNow;
        
        return cell;
    } else if (item.payload.type == GHPayloadCommitCommentEvent) {
        static NSString *CellIdentifier = @"GHFeedItemWithDescriptionTableViewCell";
        GHDescriptionTableViewCell *cell = (GHDescriptionTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (!cell) {
            cell = [[GHDescriptionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        [self updateImageView:cell.imageView atIndexPath:indexPath withGravatarID:item.actorAttributes.gravatarID];
        
        cell.textLabel.text = item.actor;
        cell.detailTextLabel.text = item.repository.fullName;
        cell.descriptionLabel.text = [self descriptionForNewsFeedItem:item];
        cell.timeLabel.text = item.creationDate.prettyShortTimeIntervalSinceNow;
        
        return cell;
    } else if (item.payload.type == GHPayloadFollowEvent) {
        static NSString *CellIdentifier = @"GHFollowEventTableViewCell";
        GHFollowEventTableViewCell *cell = (GHFollowEventTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (!cell) {
            cell = [[GHFollowEventTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        [self updateImageView:cell.imageView atIndexPath:indexPath withGravatarID:item.actorAttributes.gravatarID];
        
        GHFollowEventPayload *payload = (GHFollowEventPayload *)item.payload;
        
        cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@ started following", @""), item.actor];
        cell.targetNameLabel.text = payload.target.login;
        [self updateImageView:cell.targetImageView atIndexPath:indexPath withGravatarID:payload.target.gravatarID];
        cell.timeLabel.text = item.creationDate.prettyShortTimeIntervalSinceNow;
        
        return cell;
    } else if (item.payload.type == GHPayloadWatchEvent) {
        static NSString *CellIdentifier = @"GHFeedItemWithDescriptionTableViewCell";
        GHDescriptionTableViewCell *cell = (GHDescriptionTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (!cell) {
            cell = [[GHDescriptionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        [self updateImageView:cell.imageView atIndexPath:indexPath withGravatarID:item.actorAttributes.gravatarID];
        
        cell.textLabel.text = item.actor;
        cell.detailTextLabel.text = item.repository.fullName;
        cell.descriptionLabel.text = [self descriptionForNewsFeedItem:item];
        cell.timeLabel.text = item.creationDate.prettyShortTimeIntervalSinceNow;
        
        return cell;
    } else if (item.payload.type == GHPayloadCreateEvent) {
        static NSString *CellIdentifier = @"GHFeedItemWithDescriptionTableViewCell";
        GHDescriptionTableViewCell *cell = (GHDescriptionTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (!cell) {
            cell = [[GHDescriptionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        [self updateImageView:cell.imageView atIndexPath:indexPath withGravatarID:item.actorAttributes.gravatarID];
        
        cell.descriptionLabel.text = [self descriptionForNewsFeedItem:item];
        cell.textLabel.text = item.actor;
        cell.detailTextLabel.text = item.repository.fullName;
        cell.timeLabel.text = item.creationDate.prettyShortTimeIntervalSinceNow;
        
        return cell;
    } else if (item.payload.type == GHPayloadForkEvent) {
        static NSString *CellIdentifier = @"GHFeedItemWithDescriptionTableViewCell";
        GHDescriptionTableViewCell *cell = (GHDescriptionTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (!cell) {
            cell = [[GHDescriptionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        [self updateImageView:cell.imageView atIndexPath:indexPath withGravatarID:item.actorAttributes.gravatarID];
        
        cell.textLabel.text = item.actor;
        cell.descriptionLabel.text = [self descriptionForNewsFeedItem:item];
        cell.detailTextLabel.text = item.repository.fullName;
        cell.timeLabel.text = item.creationDate.prettyShortTimeIntervalSinceNow;
        
        return cell;
    } else if (item.payload.type == GHPayloadDeleteEvent) {
        static NSString *CellIdentifier = @"GHFeedItemWithDescriptionTableViewCell";
        GHDescriptionTableViewCell *cell = (GHDescriptionTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (!cell) {
            cell = [[GHDescriptionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        [self updateImageView:cell.imageView atIndexPath:indexPath withGravatarID:item.actorAttributes.gravatarID];
        
        cell.textLabel.text = item.actor;
        cell.descriptionLabel.text = [self descriptionForNewsFeedItem:item];
        
        NSString *repoURL = item.repository.URL;
        NSArray *components = [repoURL componentsSeparatedByString:@"/"];
        NSUInteger count = [components count];
        if (count > 1) {
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@/%@", [components objectAtIndex:count-2], [components lastObject]];
        } else {
            cell.detailTextLabel.text = item.repository.name;
        }
        cell.timeLabel.text = item.creationDate.prettyShortTimeIntervalSinceNow;
        
        return cell;
    } else if (item.payload.type == GHPayloadGollumEvent) {
        static NSString *CellIdentifier = @"GHFeedItemWithDescriptionTableViewCell";
        GHDescriptionTableViewCell *cell = (GHDescriptionTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (!cell) {
            cell = [[GHDescriptionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        [self updateImageView:cell.imageView atIndexPath:indexPath withGravatarID:item.actorAttributes.gravatarID];
        
        cell.textLabel.text = item.actor;
        cell.descriptionLabel.text = [self descriptionForNewsFeedItem:item];
        cell.detailTextLabel.text = item.repository.fullName;
        cell.timeLabel.text = item.creationDate.prettyShortTimeIntervalSinceNow;
        
        return cell;
    } else if (item.payload.type == GHPayloadGistEvent) {
        static NSString *CellIdentifier = @"GHFeedItemWithDescriptionTableViewCell";
        GHDescriptionTableViewCell *cell = (GHDescriptionTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (!cell) {
            cell = [[GHDescriptionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        [self updateImageView:cell.imageView atIndexPath:indexPath withGravatarID:item.actorAttributes.gravatarID];
        
        cell.detailTextLabel.text = nil;
        cell.textLabel.text = item.actor;
        cell.descriptionLabel.text = [self descriptionForNewsFeedItem:item];
        cell.timeLabel.text = item.creationDate.prettyShortTimeIntervalSinceNow;
        
        return cell;
    } else if (item.payload.type == GHPayloadDownloadEvent) {
        static NSString *CellIdentifier = @"GHFeedItemWithDescriptionTableViewCell";
        GHDescriptionTableViewCell *cell = (GHDescriptionTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (!cell) {
            cell = [[GHDescriptionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        [self updateImageView:cell.imageView atIndexPath:indexPath withGravatarID:item.actorAttributes.gravatarID];
        
        cell.detailTextLabel.text = item.repository.fullName;
        cell.textLabel.text = item.actor;
        cell.descriptionLabel.text = [self descriptionForNewsFeedItem:item];
        cell.timeLabel.text = item.creationDate.prettyShortTimeIntervalSinceNow;
        
        return cell;
    } else if (item.payload.type == GHPayloadPullRequestEvent) {
        static NSString *CellIdentifier = @"GHFeedItemWithDescriptionTableViewCell";
        GHDescriptionTableViewCell *cell = (GHDescriptionTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (!cell) {
            cell = [[GHDescriptionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        [self updateImageView:cell.imageView atIndexPath:indexPath withGravatarID:item.actorAttributes.gravatarID];
        
        cell.detailTextLabel.text = item.repository.fullName;
        cell.descriptionLabel.text = [self descriptionForNewsFeedItem:item];
        cell.textLabel.text = item.actor;
        cell.timeLabel.text = item.creationDate.prettyShortTimeIntervalSinceNow;
        
        return cell;
    } else if (item.payload.type == GHPayloadMemberEvent) {
        static NSString *CellIdentifier = @"GHFeedItemWithDescriptionTableViewCell";
        GHDescriptionTableViewCell *cell = (GHDescriptionTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (!cell) {
            cell = [[GHDescriptionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        [self updateImageView:cell.imageView atIndexPath:indexPath withGravatarID:item.actorAttributes.gravatarID];
        
        cell.detailTextLabel.text = item.repository.fullName;
        cell.textLabel.text = item.actor;
        cell.descriptionLabel.text = [self descriptionForNewsFeedItem:item];
        cell.timeLabel.text = item.creationDate.prettyShortTimeIntervalSinceNow;
        
        return cell;
    } else if (item.payload.type == GHPayloadIssueCommentEvent) {
        static NSString *CellIdentifier = @"GHFeedItemWithDescriptionTableViewCell";
        GHDescriptionTableViewCell *cell = (GHDescriptionTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (!cell) {
            cell = [[GHDescriptionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        [self updateImageView:cell.imageView atIndexPath:indexPath withGravatarID:item.actorAttributes.gravatarID];
        
        cell.detailTextLabel.text = item.repository.fullName;
        cell.textLabel.text = item.actor;
        cell.descriptionLabel.text = [self descriptionForNewsFeedItem:item];
        cell.timeLabel.text = item.creationDate.prettyShortTimeIntervalSinceNow;
        
        return cell;
    } else if (item.payload.type == GHPayloadForkApplyEvent) {
        static NSString *CellIdentifier = @"GHFeedItemWithDescriptionTableViewCell";
        GHDescriptionTableViewCell *cell = (GHDescriptionTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (!cell) {
            cell = [[GHDescriptionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        [self updateImageView:cell.imageView atIndexPath:indexPath withGravatarID:item.actorAttributes.gravatarID];
        
        cell.detailTextLabel.text = item.repository.fullName;
        cell.textLabel.text = item.actor;
        cell.descriptionLabel.text = [self descriptionForNewsFeedItem:item];
        cell.timeLabel.text = item.creationDate.prettyShortTimeIntervalSinceNow;
        
        return cell;
    } else if (item.payload.type == GHPayloadPublicEvent) {
        static NSString *CellIdentifier = @"GHFeedItemWithDescriptionTableViewCell";
        GHDescriptionTableViewCell *cell = (GHDescriptionTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (!cell) {
            cell = [[GHDescriptionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        [self updateImageView:cell.imageView atIndexPath:indexPath withGravatarID:item.actorAttributes.gravatarID];
        
        cell.detailTextLabel.text = item.repository.fullName;
        cell.descriptionLabel.text = [self descriptionForNewsFeedItem:item];
        cell.textLabel.text = item.actor;
        cell.timeLabel.text = item.creationDate.prettyShortTimeIntervalSinceNow;
        
        return cell;
    }
    
    return [self dummyCellWithText:item.type];
}

#pragma mark - instance methods

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
        description = @"";
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
        description = NSLocalizedString(@"applied fork commits", @"");
    } else if (item.payload.type == GHPayloadPublicEvent) {
        description = NSLocalizedString(@"open sourced", @"");
    }
    
    return description;
}

- (void)cacheHeightForTableView {
    int i = 0;
    for (GHNewsFeedItem *item in self.newsFeed.items) {
        CGFloat height = 0.0;
        CGFloat minimumHeight = 0.0;
        
#ifdef DEBUG
        minimumHeight = 15.0f;
#endif
        
        height = [GHDescriptionTableViewCell heightWithContent:[self descriptionForNewsFeedItem:item] ];
        
        [self cacheHeight:height < minimumHeight ? minimumHeight : height forRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        i++;
    }
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self cachedHeightForRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    GHNewsFeedItem *item = [self.newsFeed.items objectAtIndex:indexPath.row];
    
    if (item.payload.type == GHPayloadIssuesEvent) {
        GHIssuePayload *payload = (GHIssuePayload *)item.payload;
        GHIssueViewController *viewIssueViewController = [[GHIssueViewController alloc] 
                                                                    initWithRepository:item.repository.fullName 
                                                                    issueNumber:payload.number];
        [self.navigationController pushViewController:viewIssueViewController animated:YES];
    } else if (item.payload.type == GHPayloadPullRequestEvent) {
        GHPullRequestPayload *payload = (GHPullRequestPayload *)item.payload;
        GHIssueViewController *viewIssueViewController = [[GHIssueViewController alloc] initWithRepository:item.repository.fullName issueNumber:payload.number];
        [self.navigationController pushViewController:viewIssueViewController animated:YES];
    } else if (item.payload.type == GHPayloadPushEvent) {
        GHPushPayloadViewController *pushViewController = [[GHPushPayloadViewController alloc] initWithPayload:(GHPushPayload *)item.payload onRepository:item.repository.fullName];
        [self.navigationController pushViewController:pushViewController animated:YES];
    } else if (item.payload.type == GHPayloadWatchEvent) {
        GHRepositoryViewController *repoViewController = [[GHRepositoryViewController alloc] initWithRepositoryString:item.repository.fullName];
        [self.navigationController pushViewController:repoViewController animated:YES];
    } else if (item.payload.type == GHPayloadFollowEvent) {
        GHFollowEventPayload *payload = (GHFollowEventPayload *)item.payload;
        
        GHUserViewController *userViewController = [[GHUserViewController alloc] initWithUsername:payload.target.login];
        [self.navigationController pushViewController:userViewController animated:YES];
    } else if (item.payload.type == GHPayloadCreateEvent) {
        NSString *repo = item.repository.fullName;
        
        GHRepositoryViewController *repoViewController = [[GHRepositoryViewController alloc] initWithRepositoryString:repo];
        [self.navigationController pushViewController:repoViewController animated:YES];
    } else if (item.payload.type == GHPayloadIssueCommentEvent) {
        GHIssuesCommentPayload *payload = (GHIssuesCommentPayload *)item.payload;
        
        GHIssueViewController *viewIssueViewController = [[GHIssueViewController alloc] initWithRepository:item.repository.fullName issueNumber:payload.issueID];
        [self.navigationController pushViewController:viewIssueViewController animated:YES];
    } else if (item.payload.type == GHPayloadPublicEvent) {
        GHRepositoryViewController *repoViewController = [[GHRepositoryViewController alloc] initWithRepositoryString:item.repository.fullName];
        [self.navigationController pushViewController:repoViewController animated:YES];
    } else if (item.payload.type == GHPayloadCommitCommentEvent) {
        GHRepositoryViewController *repoViewController = [[GHRepositoryViewController alloc] initWithRepositoryString:item.repository.fullName];
        [self.navigationController pushViewController:repoViewController animated:YES];
    } else if (item.payload.type == GHPayloadDeleteEvent) {
        GHRepositoryViewController *repoViewController = [[GHRepositoryViewController alloc] initWithRepositoryString:
                                                                 [NSString stringWithFormat:@"%@/%@", item.repository.owner, item.repository.name] ];
        [self.navigationController pushViewController:repoViewController animated:YES];
    } else if (item.payload.type == GHPayloadDownloadEvent) {
        GHRepositoryViewController *repoViewController = [[GHRepositoryViewController alloc] initWithRepositoryString:
                                                                 [NSString stringWithFormat:@"%@/%@", item.repository.owner, item.repository.name] ];
        [self.navigationController pushViewController:repoViewController animated:YES];
    } else if (item.payload.type == GHPayloadForkApplyEvent) {
        GHRepositoryViewController *repoViewController = [[GHRepositoryViewController alloc] initWithRepositoryString:
                                                                 [NSString stringWithFormat:@"%@/%@", item.repository.owner, item.repository.name] ];
        [self.navigationController pushViewController:repoViewController animated:YES];
    } else if (item.payload.type == GHPayloadGollumEvent) {
        GHRepositoryViewController *repoViewController = [[GHRepositoryViewController alloc] initWithRepositoryString:
                                                                 [NSString stringWithFormat:@"%@/%@", item.repository.owner, item.repository.name] ];
        [self.navigationController pushViewController:repoViewController animated:YES];
    } else if (item.payload.type == GHPayloadForkEvent) {
        GHRepositoryViewController *repoViewController = [[GHRepositoryViewController alloc] initWithRepositoryString:
                                                                 item.repository.fullName ];
        [self.navigationController pushViewController:repoViewController animated:YES];
    } else if (item.payload.type == GHPayloadMemberEvent) {
        GHMemberEventPayload *payload = (GHMemberEventPayload *)item.payload;
        
        GHUserViewController *userViewController = [[GHUserViewController alloc] initWithUsername:payload.member.login];
        [self.navigationController pushViewController:userViewController animated:YES];
    } else if (item.payload.type == GHPayloadGistEvent) {
        GHGistEventPayload *payload = (GHGistEventPayload *)item.payload;
        
        GHGistViewController *gistViewController = [[GHGistViewController alloc] initWithID:payload.gistID];
        [self.navigationController pushViewController:gistViewController animated:YES];
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
        _newsFeed = [decoder decodeObjectForKey:@"newsFeed"];
    }
    return self;
}

@end
