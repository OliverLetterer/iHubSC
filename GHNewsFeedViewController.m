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
        [_newsFeed release];
        _newsFeed = [newsFeed retain];
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

- (void)dealloc {
    [_newsFeed release];
    [super dealloc];
}

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
            cell = [[[GHDescriptionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        }
        
        GHIssuePayload *payload = (GHIssuePayload *)item.payload;
        
        [self updateImageView:cell.imageView atIndexPath:indexPath withGravatarID:item.actorAttributes.gravatarID];
        
        cell.textLabel.text = item.actor;
        cell.detailTextLabel.text = item.repository.fullName;
        cell.timeLabel.text = item.creationDate.prettyShortTimeIntervalSinceNow;
        
        GHIssue *issue = [GHIssue issueFromDatabaseOnRepository:item.repository.fullName withNumber:payload.number];
        
        if (issue) {
            cell.descriptionLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@ Issue %@:\n\n%@", @""), payload.action, payload.number, issue.title];
        } else {
            [GHIssue issueOnRepository:[NSString stringWithFormat:@"%@/%@", item.repository.owner, item.repository.name] 
                            withNumber:payload.number 
                 useDatabaseIfPossible:YES 
                     completionHandler:^(GHIssue *issue, NSError *error, BOOL didDownload) {
                         if (error) {
                             [self handleError:error];
                         } else {
                             NSString *description = [NSString stringWithFormat:NSLocalizedString(@"%@ Issue %@:\n\n%@", @""), payload.action, payload.number, issue.title];
                             CGFloat height = [GHDescriptionTableViewCell heightWithContent:description];
                             
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
            cell = [[[GHDescriptionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        }
        
        GHPushPayload *payload = (GHPushPayload *)item.payload;
        
        [self updateImageView:cell.imageView atIndexPath:indexPath withGravatarID:item.actorAttributes.gravatarID];
        cell.detailTextLabel.text = item.repository.fullName;
        cell.textLabel.text = item.actor;
        cell.descriptionLabel.text = [NSString stringWithFormat:NSLocalizedString(@"pushed to %@ (%d)\n\n%@", @""), payload.branch, payload.commits.count, payload.previewString];
        cell.timeLabel.text = item.creationDate.prettyShortTimeIntervalSinceNow;
        
        return cell;
    } else if (item.payload.type == GHPayloadCommitCommentEvent) {
        static NSString *CellIdentifier = @"GHFeedItemWithDescriptionTableViewCell";
        GHDescriptionTableViewCell *cell = (GHDescriptionTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (!cell) {
            cell = [[[GHDescriptionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        }
        
        [self updateImageView:cell.imageView atIndexPath:indexPath withGravatarID:item.actorAttributes.gravatarID];
        
        cell.textLabel.text = item.actor;
        cell.detailTextLabel.text = item.repository.fullName;
        cell.descriptionLabel.text = NSLocalizedString(@"commented on a commit", @"");
        cell.timeLabel.text = item.creationDate.prettyShortTimeIntervalSinceNow;
        
        return cell;
    } else if (item.payload.type == GHPayloadFollowEvent) {
        static NSString *CellIdentifier = @"GHFollowEventTableViewCell";
        GHFollowEventTableViewCell *cell = (GHFollowEventTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (!cell) {
            cell = [[[GHFollowEventTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
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
            cell = [[[GHDescriptionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        }
        [self updateImageView:cell.imageView atIndexPath:indexPath withGravatarID:item.actorAttributes.gravatarID];
        
        GHWatchEventPayload *payload = (GHWatchEventPayload *)item.payload;
        
        cell.textLabel.text = item.actor;
        cell.detailTextLabel.text = item.repository.fullName;
        cell.descriptionLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@ watching", @""), payload.action];
        cell.timeLabel.text = item.creationDate.prettyShortTimeIntervalSinceNow;
        
        return cell;
    } else if (item.payload.type == GHPayloadCreateEvent) {
        static NSString *CellIdentifier = @"GHFeedItemWithDescriptionTableViewCell";
        GHDescriptionTableViewCell *cell = (GHDescriptionTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (!cell) {
            cell = [[[GHDescriptionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        }
        [self updateImageView:cell.imageView atIndexPath:indexPath withGravatarID:item.actorAttributes.gravatarID];
        
        GHCreateEventPayload *payload = (GHCreateEventPayload *)item.payload;
        
        cell.textLabel.text = item.actor;
        if (payload.objectType == GHCreateEventObjectRepository) {
            cell.descriptionLabel.text = NSLocalizedString(@"created repository", @"");
            cell.detailTextLabel.text = item.repository.fullName;
        } else if (payload.objectType == GHCreateEventObjectBranch) {
            cell.descriptionLabel.text = [NSString stringWithFormat:NSLocalizedString(@"created branch %@", @""), payload.ref];
            cell.detailTextLabel.text = item.repository.fullName;
        } else if (payload.objectType == GHCreateEventObjectTag) {
            cell.descriptionLabel.text = [NSString stringWithFormat:NSLocalizedString(@"created tag %@", @""), payload.ref];
            cell.detailTextLabel.text = item.repository.fullName;
        } else {
            cell.textLabel.text = @"__UNKNWON_CREATE_EVENT__";
            cell.detailTextLabel.text = nil;
        }
        cell.timeLabel.text = item.creationDate.prettyShortTimeIntervalSinceNow;
        
        return cell;
    } else if (item.payload.type == GHPayloadForkEvent) {
        static NSString *CellIdentifier = @"GHFeedItemWithDescriptionTableViewCell";
        GHDescriptionTableViewCell *cell = (GHDescriptionTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (!cell) {
            cell = [[[GHDescriptionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        }
        [self updateImageView:cell.imageView atIndexPath:indexPath withGravatarID:item.actorAttributes.gravatarID];
        
        cell.textLabel.text = item.actor;
        cell.descriptionLabel.text = NSLocalizedString(@"forked repository", @"");
        cell.detailTextLabel.text = item.repository.fullName;
        cell.timeLabel.text = item.creationDate.prettyShortTimeIntervalSinceNow;
        
        return cell;
    } else if (item.payload.type == GHPayloadDeleteEvent) {
        static NSString *CellIdentifier = @"GHFeedItemWithDescriptionTableViewCell";
        GHDescriptionTableViewCell *cell = (GHDescriptionTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (!cell) {
            cell = [[[GHDescriptionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        }
        [self updateImageView:cell.imageView atIndexPath:indexPath withGravatarID:item.actorAttributes.gravatarID];
        
        GHDeleteEventPayload *payload = (GHDeleteEventPayload *)item.payload;
        
        cell.textLabel.text = item.actor;
        cell.descriptionLabel.text = [NSString stringWithFormat:NSLocalizedString(@"deleted %@ %@", @""), payload.refType, payload.ref];
        
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
            cell = [[[GHDescriptionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        }
        [self updateImageView:cell.imageView atIndexPath:indexPath withGravatarID:item.actorAttributes.gravatarID];
        
        GHGollumEventPayload *payload = (GHGollumEventPayload *)item.payload;
        
        cell.textLabel.text = item.actor;
        cell.descriptionLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@ %@ in wiki", @""), payload.action, payload.pageName];
        cell.detailTextLabel.text = item.repository.fullName;
        cell.timeLabel.text = item.creationDate.prettyShortTimeIntervalSinceNow;
        
        return cell;
    } else if (item.payload.type == GHPayloadGistEvent) {
        static NSString *CellIdentifier = @"GHFeedItemWithDescriptionTableViewCell";
        GHDescriptionTableViewCell *cell = (GHDescriptionTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (!cell) {
            cell = [[[GHDescriptionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        }
        [self updateImageView:cell.imageView atIndexPath:indexPath withGravatarID:item.actorAttributes.gravatarID];
        
        GHGistEventPayload *payload = (GHGistEventPayload *)item.payload;
        
        NSString *action = payload.action;
        if ([action hasSuffix:@"e"]) {
            action = [action stringByAppendingString:@"d"];
        } else {
            action = [action stringByAppendingString:@"ed"];
        }
        
        cell.detailTextLabel.text = nil;
        cell.textLabel.text = item.actor;
        cell.descriptionLabel.text = [NSString stringWithFormat:@"%@ %@:\n\n%@", action, payload.name, payload.descriptionGist ? payload.descriptionGist : payload.snippet];
        cell.timeLabel.text = item.creationDate.prettyShortTimeIntervalSinceNow;
        
        return cell;
    } else if (item.payload.type == GHPayloadDownloadEvent) {
        static NSString *CellIdentifier = @"GHFeedItemWithDescriptionTableViewCell";
        GHDescriptionTableViewCell *cell = (GHDescriptionTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (!cell) {
            cell = [[[GHDescriptionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        }
        [self updateImageView:cell.imageView atIndexPath:indexPath withGravatarID:item.actorAttributes.gravatarID];
        
        GHDownloadEventPayload *payload = (GHDownloadEventPayload *)item.payload;
        
        cell.detailTextLabel.text = item.repository.fullName;
        cell.textLabel.text = item.actor;
        cell.descriptionLabel.text = [NSString stringWithFormat:NSLocalizedString(@"uploaded file:%@", @""), item.actor, [payload.URL lastPathComponent]];
        cell.timeLabel.text = item.creationDate.prettyShortTimeIntervalSinceNow;
        
        return cell;
    } else if (item.payload.type == GHPayloadPullRequestEvent) {
        static NSString *CellIdentifier = @"GHFeedItemWithDescriptionTableViewCell";
        GHDescriptionTableViewCell *cell = (GHDescriptionTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (!cell) {
            cell = [[[GHDescriptionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        }
        [self updateImageView:cell.imageView atIndexPath:indexPath withGravatarID:item.actorAttributes.gravatarID];
        
        GHPullRequestPayload *payload = (GHPullRequestPayload *)item.payload;
        
        NSString *description = nil;
        
        if (payload.pullRequest) {
            NSString *additionsString = [NSString stringWithFormat:NSLocalizedString(@"%@ %@", @""), payload.pullRequest.additions, [payload.pullRequest.additions intValue] == 1 ? NSLocalizedString(@"addition", @"") : NSLocalizedString(@"additions", @"") ];
            NSString *deletionsString = [NSString stringWithFormat:NSLocalizedString(@"%@ %@", @""), payload.pullRequest.deletions, [payload.pullRequest.deletions intValue] == 1 ? NSLocalizedString(@"deletion", @"") : NSLocalizedString(@"deletions", @"") ];
            NSString *commitsString = [NSString stringWithFormat:NSLocalizedString(@"%@ %@", @""), payload.pullRequest.commits, [payload.pullRequest.commits intValue] == 1 ? NSLocalizedString(@"commit", @"") : NSLocalizedString(@"commits", @"") ];
            
            description = [NSString stringWithFormat:NSLocalizedString(@"%@ with %@ and %@", @""), commitsString, additionsString, deletionsString];
        }
        description = [NSString stringWithFormat:NSLocalizedString(@"%@ pull request %@:\n\n%@", @""), payload.action, payload.number, description];
        
        cell.detailTextLabel.text = item.repository.fullName;
        cell.descriptionLabel.text = description;
        cell.textLabel.text = item.actor;
        cell.timeLabel.text = item.creationDate.prettyShortTimeIntervalSinceNow;
        
        return cell;
    } else if (item.payload.type == GHPayloadMemberEvent) {
        static NSString *CellIdentifier = @"GHFeedItemWithDescriptionTableViewCell";
        GHDescriptionTableViewCell *cell = (GHDescriptionTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (!cell) {
            cell = [[[GHDescriptionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        }
        [self updateImageView:cell.imageView atIndexPath:indexPath withGravatarID:item.actorAttributes.gravatarID];
        
        GHMemberEventPayload *payload = (GHMemberEventPayload *)item.payload;
        
        cell.detailTextLabel.text = item.repository.fullName;
        cell.textLabel.text = item.actor;
        cell.descriptionLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@ %@", @""), payload.action, payload.member.login];
        cell.timeLabel.text = item.creationDate.prettyShortTimeIntervalSinceNow;
        
        return cell;
    } else if (item.payload.type == GHPayloadIssueCommentEvent) {
        static NSString *CellIdentifier = @"GHFeedItemWithDescriptionTableViewCell";
        GHDescriptionTableViewCell *cell = (GHDescriptionTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (!cell) {
            cell = [[[GHDescriptionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        }
        [self updateImageView:cell.imageView atIndexPath:indexPath withGravatarID:item.actorAttributes.gravatarID];
        
        GHIssuesCommentPayload *payload = (GHIssuesCommentPayload *)item.payload;
        
        cell.detailTextLabel.text = item.repository.fullName;
        cell.textLabel.text = item.actor;
        cell.descriptionLabel.text = [NSString stringWithFormat:NSLocalizedString(@"commented on Issue %@", @""), payload.issueID];
        cell.timeLabel.text = item.creationDate.prettyShortTimeIntervalSinceNow;
        
        return cell;
    } else if (item.payload.type == GHPayloadForkApplyEvent) {
        static NSString *CellIdentifier = @"GHFeedItemWithDescriptionTableViewCell";
        GHDescriptionTableViewCell *cell = (GHDescriptionTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (!cell) {
            cell = [[[GHDescriptionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        }
        [self updateImageView:cell.imageView atIndexPath:indexPath withGravatarID:item.actorAttributes.gravatarID];
        
        GHForkApplyEventPayload *payload = (GHForkApplyEventPayload *)item.payload;
        
        cell.detailTextLabel.text = item.repository.fullName;
        cell.textLabel.text = item.actor;
        cell.descriptionLabel.text = [NSString stringWithFormat:NSLocalizedString(@"applied fork commits:\n\n%@", @""), payload.commit];
        cell.timeLabel.text = item.creationDate.prettyShortTimeIntervalSinceNow;
        
        return cell;
    } else if (item.payload.type == GHPayloadPublicEvent) {
        static NSString *CellIdentifier = @"GHFeedItemWithDescriptionTableViewCell";
        GHDescriptionTableViewCell *cell = (GHDescriptionTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (!cell) {
            cell = [[[GHDescriptionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        }
        [self updateImageView:cell.imageView atIndexPath:indexPath withGravatarID:item.actorAttributes.gravatarID];
        
        cell.detailTextLabel.text = item.repository.fullName;
        cell.descriptionLabel.text = NSLocalizedString(@"open sourced", @"");
        cell.textLabel.text = item.actor;
        cell.timeLabel.text = item.creationDate.prettyShortTimeIntervalSinceNow;
        
        return cell;
    }
    
    return [self dummyCellWithText:item.type];
}

#pragma mark - instance methods

- (void)cacheHeightForTableView {
    int i = 0;
    for (GHNewsFeedItem *item in self.newsFeed.items) {
        CGFloat height = 0.0;
        CGFloat minimumHeight = 0.0;
        
        if (item.payload.type == GHPayloadIssuesEvent) {
            // this is the height for an issue cell, we will display the whole issue
            GHIssuePayload *payload = (GHIssuePayload *)item.payload;
            
            if ([GHIssue isIssueAvailableForRepository:item.repository.fullName withNumber:payload.number]) {
                GHIssue *issue = [GHIssue issueFromDatabaseOnRepository:item.repository.fullName 
                                                             withNumber:payload.number];
                
                NSString *description = [NSString stringWithFormat:NSLocalizedString(@"%@ Issue %@:\n\n%@", @""), payload.action, payload.number, issue.title];
                height = [GHDescriptionTableViewCell heightWithContent:description];
            } else {
                height = [GHDescriptionTableViewCell heightWithContent:nil];
            }
        } else if (item.payload.type == GHPayloadPushEvent) {
            GHPushPayload *payload = (GHPushPayload *)item.payload;
            // this is a commit / push message, we will display max 2 commits
            height = [GHDescriptionTableViewCell heightWithContent:[NSString stringWithFormat:NSLocalizedString(@"pushed to %@ (%d)\n\n%@", @""), payload.branch, payload.commits.count, payload.previewString]];
        } else if(item.payload.type == GHPayloadCommitCommentEvent) {
            height = [GHDescriptionTableViewCell heightWithContent:NSLocalizedString(@"commented on a commit", @"")];
        } else if(item.payload.type == GHPayloadFollowEvent) {
            height = [GHDescriptionTableViewCell heightWithContent:nil];
        } else if(item.payload.type == GHPayloadWatchEvent) {
            GHWatchEventPayload *payload = (GHWatchEventPayload *)item.payload;
            height = [GHDescriptionTableViewCell heightWithContent:[NSString stringWithFormat:NSLocalizedString(@"%@ watching", @""), payload.action]];
        } else if(item.payload.type == GHPayloadCreateEvent) {
            GHCreateEventPayload *payload = (GHCreateEventPayload *)item.payload;
            NSString *description = nil;
            if (payload.objectType == GHCreateEventObjectRepository) {
                description = NSLocalizedString(@"created repository", @"");
            } else if (payload.objectType == GHCreateEventObjectBranch) {
                description = [NSString stringWithFormat:NSLocalizedString(@"created branch %@", @""), payload.ref];
            } else if (payload.objectType == GHCreateEventObjectTag) {
                description = [NSString stringWithFormat:NSLocalizedString(@"created tag %@", @""), payload.ref];
            } else {
                description = @"__UNKNWON_CREATE_EVENT__";
            }
            height = [GHDescriptionTableViewCell heightWithContent:description];
        } else if(item.payload.type == GHPayloadForkEvent) {
            height = [GHDescriptionTableViewCell heightWithContent:NSLocalizedString(@"forked repository", @"")];
        } else if(item.payload.type == GHPayloadDeleteEvent) {
            GHDeleteEventPayload *payload = (GHDeleteEventPayload *)item.payload;
            height = [GHDescriptionTableViewCell heightWithContent:[NSString stringWithFormat:NSLocalizedString(@"deleted %@ %@", @""), payload.refType, payload.ref]];
        } else if(item.payload.type == GHPayloadGollumEvent) {
            GHGollumEventPayload *payload = (GHGollumEventPayload *)item.payload;
            
            height = [GHDescriptionTableViewCell heightWithContent:[NSString stringWithFormat:NSLocalizedString(@"%@ %@ in wiki", @""), payload.action, payload.pageName]];
        } else if(item.payload.type == GHPayloadGistEvent) {
            GHGistEventPayload *payload = (GHGistEventPayload *)item.payload;
            
            NSString *action = payload.action;
            if ([action hasSuffix:@"e"]) {
                action = [action stringByAppendingString:@"d"];
            } else {
                action = [action stringByAppendingString:@"ed"];
            }
            
            NSString *description = [NSString stringWithFormat:@"%@ %@:\n\n%@", action, payload.name, payload.descriptionGist ? payload.descriptionGist : payload.snippet];
            
            height = [GHDescriptionTableViewCell heightWithContent:description];
        } else if(item.payload.type == GHPayloadDownloadEvent) {
            // this is the height for an issue cell, we will display the whole issue
            GHDownloadEventPayload *payload = (GHDownloadEventPayload *)item.payload;
            NSString *description = [NSString stringWithFormat:NSLocalizedString(@"uploaded file:%@", @""), item.actor, [payload.URL lastPathComponent]];
            height = [GHDescriptionTableViewCell heightWithContent:description];
        } else if(item.payload.type == GHPayloadPullRequestEvent) {
            // this is the height for an issue cell, we will display the whole issue
            GHPullRequestPayload *payload = (GHPullRequestPayload *)item.payload;
            
            NSString *description = nil;
            
            if (payload.pullRequest) {
                NSString *additionsString = [NSString stringWithFormat:NSLocalizedString(@"%@ %@", @""), payload.pullRequest.additions, [payload.pullRequest.additions intValue] == 1 ? NSLocalizedString(@"addition", @"") : NSLocalizedString(@"additions", @"") ];
                NSString *deletionsString = [NSString stringWithFormat:NSLocalizedString(@"%@ %@", @""), payload.pullRequest.deletions, [payload.pullRequest.deletions intValue] == 1 ? NSLocalizedString(@"deletion", @"") : NSLocalizedString(@"deletions", @"") ];
                NSString *commitsString = [NSString stringWithFormat:NSLocalizedString(@"%@ %@", @""), payload.pullRequest.commits, [payload.pullRequest.commits intValue] == 1 ? NSLocalizedString(@"commit", @"") : NSLocalizedString(@"commits", @"") ];
                
                description = [NSString stringWithFormat:NSLocalizedString(@"%@ with %@ and %@", @""), commitsString, additionsString, deletionsString];
            }
            description = [NSString stringWithFormat:NSLocalizedString(@"%@ pull request %@:\n\n%@", @""), payload.action, payload.number, description];
            
            height = [GHDescriptionTableViewCell heightWithContent:description];
        } else if(item.payload.type == GHPayloadMemberEvent) {
            GHMemberEventPayload *payload = (GHMemberEventPayload *)item.payload;
            
            NSString *description = [NSString stringWithFormat:NSLocalizedString(@"%@ %@", @""), payload.action, payload.member.login];
            height = [GHDescriptionTableViewCell heightWithContent:description];
        } else if(item.payload.type == GHPayloadIssueCommentEvent) {
            GHIssuesCommentPayload *payload = (GHIssuesCommentPayload *)item.payload;
            height = [GHDescriptionTableViewCell heightWithContent:[NSString stringWithFormat:NSLocalizedString(@"commented on Issue %@", @""), payload.issueID]];
        } else if(item.payload.type == GHPayloadForkApplyEvent) {
            GHForkApplyEventPayload *payload = (GHForkApplyEventPayload *)item.payload;
            NSString *description = [NSString stringWithFormat:NSLocalizedString(@"applied fork commits:\n\n%@", @""), payload.commit];
            
            height = [GHDescriptionTableViewCell heightWithContent:description];
        } else if (item.payload.type == GHPayloadPublicEvent) {
            height = [GHDescriptionTableViewCell heightWithContent:NSLocalizedString(@"open sourced", @"")];
        } else {
#if DEBUG
            minimumHeight = 15.0f;
#else
            minimumHeight = 0.0f;
#endif
        }
        
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
        GHIssueViewController *viewIssueViewController = [[[GHIssueViewController alloc] 
                                                                    initWithRepository:item.repository.fullName 
                                                                    issueNumber:payload.number] autorelease];
        [self.navigationController pushViewController:viewIssueViewController animated:YES];
    } else if (item.payload.type == GHPayloadPullRequestEvent) {
        GHPullRequestPayload *payload = (GHPullRequestPayload *)item.payload;
        GHIssueViewController *viewIssueViewController = [[[GHIssueViewController alloc] initWithRepository:item.repository.fullName issueNumber:payload.number] autorelease];
        [self.navigationController pushViewController:viewIssueViewController animated:YES];
    } else if (item.payload.type == GHPayloadPushEvent) {
        GHPushPayloadViewController *pushViewController = [[[GHPushPayloadViewController alloc] initWithPayload:(GHPushPayload *)item.payload onRepository:item.repository.fullName] autorelease];
        [self.navigationController pushViewController:pushViewController animated:YES];
    } else if (item.payload.type == GHPayloadWatchEvent) {
        GHRepositoryViewController *repoViewController = [[[GHRepositoryViewController alloc] initWithRepositoryString:item.repository.fullName] autorelease];
        [self.navigationController pushViewController:repoViewController animated:YES];
    } else if (item.payload.type == GHPayloadFollowEvent) {
        GHFollowEventPayload *payload = (GHFollowEventPayload *)item.payload;
        
        GHUserViewController *userViewController = [[[GHUserViewController alloc] initWithUsername:payload.target.login] autorelease];
        [self.navigationController pushViewController:userViewController animated:YES];
    } else if (item.payload.type == GHPayloadCreateEvent) {
        NSString *repo = item.repository.fullName;
        
        GHRepositoryViewController *repoViewController = [[[GHRepositoryViewController alloc] initWithRepositoryString:repo] autorelease];
        [self.navigationController pushViewController:repoViewController animated:YES];
    } else if (item.payload.type == GHPayloadIssueCommentEvent) {
        GHIssuesCommentPayload *payload = (GHIssuesCommentPayload *)item.payload;
        
        GHIssueViewController *viewIssueViewController = [[[GHIssueViewController alloc] initWithRepository:item.repository.fullName issueNumber:payload.issueID] autorelease];
        [self.navigationController pushViewController:viewIssueViewController animated:YES];
    } else if (item.payload.type == GHPayloadPublicEvent) {
        GHRepositoryViewController *repoViewController = [[[GHRepositoryViewController alloc] initWithRepositoryString:item.repository.fullName] autorelease];
        [self.navigationController pushViewController:repoViewController animated:YES];
    } else if (item.payload.type == GHPayloadCommitCommentEvent) {
        GHRepositoryViewController *repoViewController = [[[GHRepositoryViewController alloc] initWithRepositoryString:item.repository.fullName] autorelease];
        [self.navigationController pushViewController:repoViewController animated:YES];
    } else if (item.payload.type == GHPayloadDeleteEvent) {
        GHRepositoryViewController *repoViewController = [[[GHRepositoryViewController alloc] initWithRepositoryString:
                                                                 [NSString stringWithFormat:@"%@/%@", item.repository.owner, item.repository.name] ] autorelease];
        [self.navigationController pushViewController:repoViewController animated:YES];
    } else if (item.payload.type == GHPayloadDownloadEvent) {
        GHRepositoryViewController *repoViewController = [[[GHRepositoryViewController alloc] initWithRepositoryString:
                                                                 [NSString stringWithFormat:@"%@/%@", item.repository.owner, item.repository.name] ] autorelease];
        [self.navigationController pushViewController:repoViewController animated:YES];
    } else if (item.payload.type == GHPayloadForkApplyEvent) {
        GHRepositoryViewController *repoViewController = [[[GHRepositoryViewController alloc] initWithRepositoryString:
                                                                 [NSString stringWithFormat:@"%@/%@", item.repository.owner, item.repository.name] ] autorelease];
        [self.navigationController pushViewController:repoViewController animated:YES];
    } else if (item.payload.type == GHPayloadGollumEvent) {
        GHRepositoryViewController *repoViewController = [[[GHRepositoryViewController alloc] initWithRepositoryString:
                                                                 [NSString stringWithFormat:@"%@/%@", item.repository.owner, item.repository.name] ] autorelease];
        [self.navigationController pushViewController:repoViewController animated:YES];
    } else if (item.payload.type == GHPayloadForkEvent) {
        GHRepositoryViewController *repoViewController = [[[GHRepositoryViewController alloc] initWithRepositoryString:
                                                                 item.repository.fullName ] autorelease];
        [self.navigationController pushViewController:repoViewController animated:YES];
    } else if (item.payload.type == GHPayloadMemberEvent) {
        GHMemberEventPayload *payload = (GHMemberEventPayload *)item.payload;
        
        GHUserViewController *userViewController = [[[GHUserViewController alloc] initWithUsername:payload.member.login] autorelease];
        [self.navigationController pushViewController:userViewController animated:YES];
    } else if (item.payload.type == GHPayloadGistEvent) {
        GHGistEventPayload *payload = (GHGistEventPayload *)item.payload;
        
        GHGistViewController *gistViewController = [[[GHGistViewController alloc] initWithID:payload.gistID] autorelease];
        [self.navigationController pushViewController:gistViewController animated:YES];
    } else {
        [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
}

#pragma mark Keyed Archiving

- (void)encodeWithCoder:(NSCoder *)encoder {
    [super encodeWithCoder:encoder];
    [encoder encodeObject:_newsFeed forKey:@"newsFeed"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super initWithCoder:decoder])) {
        _newsFeed = [[decoder decodeObjectForKey:@"newsFeed"] retain];
    }
    return self;
}

@end
