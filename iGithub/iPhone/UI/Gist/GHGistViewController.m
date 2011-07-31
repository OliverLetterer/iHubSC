//
//  GHGistViewController.m
//  iGithub
//
//  Created by Oliver Letterer on 05.05.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHGistViewController.h"
#import "GithubAPI.h"
#import "GHDescriptionTableViewCell.h"
#import "GHCollapsingAndSpinningTableViewCell.h"
#import "NSString+Additions.h"
#import "GHUserViewController.h"
#import "GHViewCloudFileViewController.h"
#import "GHNewCommentTableViewCell.h"
#import "GHWebViewViewController.h"
#import "ANNotificationQueue.h"

#define kUITableViewSectionInfo 0
#define kUITableViewSectionFiles 1
#define kUITableViewSectionForks 2
#define kUITableViewSectionComments 3

#define kUITableViewSections 4

@implementation GHGistViewController

@synthesize ID=_ID, gist=_gist, comments=_comments;
@synthesize lastUserComment=_lastUserComment;

#pragma mark - setters and getters

- (void)setID:(NSString *)ID {
    _ID = [ID copy];
    
    self.isDownloadingEssentialData = YES;
    [GHAPIGistV3 gistWithID:_ID completionHandler:^(GHAPIGistV3 *gist, NSError *error) {
        self.isDownloadingEssentialData = NO;
        if (error) {
            [self handleError:error];
        } else {
            self.gist = gist;
            [self.tableView reloadData];
        }
    }];
}

- (BOOL)isGistOwnedByAuthenticatedUser {
    return [[GHAPIAuthenticationManager sharedInstance].authenticatedUser isEqualToUser:self.gist.user];
}

#pragma mark - Initialization

- (id)initWithID:(NSString *)ID {
    if ((self = [super initWithStyle:UITableViewStylePlain])) {
        // Custom initialization
        self.ID = ID;
        self.title = NSLocalizedString(@"Gist", @"");
    }
    return self;
}

#pragma mark - GHNewCommentTableViewCellDelegate

- (void)newCommentTableViewCell:(GHNewCommentTableViewCell *)cell didEnterText:(NSString *)text {
    UITextView *textView = cell.textView;
    [textView resignFirstResponder];
    
    [GHAPIGistV3 postComment:textView.text 
          forGistWithID:self.gist.ID 
      completionHandler:^(GHAPIGistCommentV3 *comment, NSError *error) {
          if (error) {
              [self handleError:error];
          } else {
              [self.comments addObject:comment];
              [self cacheHeightForComments];
              
              [self.tableView beginUpdates];
              
              [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:[self.comments count]+1 inSection:kUITableViewSectionComments]] withRowAnimation:UITableViewRowAnimationFade];
              [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:[self.comments count] inSection:kUITableViewSectionComments]] withRowAnimation:UITableViewRowAnimationFade];
              
              [self.tableView endUpdates];
              
              textView.text = nil;
          }
      }];
}

#pragma mark - instance methods

- (void)cacheHeightForComments {
    DTAttributedTextView *textView = [[DTAttributedTextView alloc] initWithFrame:CGRectZero];
    [self.comments enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        GHAPIGistCommentV3 *comment = obj;
        CGFloat height = [GHAttributedTableViewCell heightWithAttributedString:comment.attributedBody 
                                                          inAttributedTextView:textView];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:idx+1 inSection:kUITableViewSectionComments];
        [self cacheHeight:height forRowAtIndexPath:indexPath];
    }];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.comments.count+1 inSection:kUITableViewSectionComments];
    [self cacheHeight:GHNewCommentTableViewCellHeight forRowAtIndexPath:indexPath];
}

#pragma mark - UIExpandableTableViewDatasource

- (BOOL)tableView:(UIExpandableTableView *)tableView canExpandSection:(NSInteger)section {
    return section == kUITableViewSectionFiles || section == kUITableViewSectionForks || section == kUITableViewSectionComments;
}

- (BOOL)tableView:(UIExpandableTableView *)tableView needsToDownloadDataForExpandableSection:(NSInteger)section {
    if (section == kUITableViewSectionComments) {
        return self.comments == nil;
    }
    return NO;
}

- (UITableViewCell<UIExpandingTableViewCell> *)tableView:(UIExpandableTableView *)tableView expandingCellForSection:(NSInteger)section {
    NSString *CellIdientifier = @"UICollapsingAndSpinningTableViewCell";
    
    GHCollapsingAndSpinningTableViewCell *cell = (GHCollapsingAndSpinningTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdientifier];
    
    if (cell == nil) {
        cell = [[GHCollapsingAndSpinningTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdientifier];
    }
    
    if (section == kUITableViewSectionFiles) {
        cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Files (%d)", @""), self.gist.files.count ];
    } else if (section == kUITableViewSectionForks) {
        cell.textLabel.text = NSLocalizedString(@"Forked by", @"");
    } else if (section == kUITableViewSectionComments) {
        cell.textLabel.text = NSLocalizedString(@"Comments", @"");
    }
    
    return cell;
}

#pragma mark - UIExpandableTableViewDelegate

- (void)tableView:(UIExpandableTableView *)tableView downloadDataForExpandableSection:(NSInteger)section {
    if (section == kUITableViewSectionComments) {
        [GHAPIGistV3 commentsForGistWithID:self.gist.ID completionHandler:^(NSMutableArray *comments, NSError *error) {
            if (error) {
                [self handleError:error];
                [tableView cancelDownloadInSection:section];
            } else {
                self.comments = comments;
                [self cacheHeightForComments];
                [tableView expandSection:section animated:YES];
            }
        }];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    
    if (!self.gist) {
        return 0;
    }
    
    // gist itself
    return kUITableViewSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (section == kUITableViewSectionInfo) {
        return 2;
    } else if (section == kUITableViewSectionFiles) {
        return self.gist.files.count + 1;
    } else if (section == kUITableViewSectionForks) {
        return self.gist.forks.count + 1;
    } else if (section == kUITableViewSectionComments) {
        return self.comments.count + 2;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == kUITableViewSectionInfo) {
        if (indexPath.row == 0) {
            NSString *CellIdentifier = @"GHFeedItemWithDescriptionTableViewCell";
            
            GHDescriptionTableViewCell *cell = (GHDescriptionTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[GHDescriptionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            
            GHAPIGistV3 *gist = self.gist;
            
            cell.textLabel.text = [NSString stringWithFormat:@"Gist: %@", gist.ID];
            
            cell.descriptionLabel.text = gist.description;
            cell.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Created %@ ago", @""), gist.createdAt.prettyTimeIntervalSinceNow];
            
            if ([gist.public boolValue]) {
                cell.imageView.image = [UIImage imageNamed:@"GHClipBoard.png"];
            } else {
                cell.imageView.image = [UIImage imageNamed:@"GHClipBoardPrivate.png"];
            }
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            return cell;
        } else if (indexPath.row == 1) {
            NSString *CellIdentifier = @"DetailsTableViewCell";
            
            GHTableViewCellWithLinearGradientBackgroundView *cell = (GHTableViewCellWithLinearGradientBackgroundView *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (!cell) {
                cell = [[GHTableViewCellWithLinearGradientBackgroundView alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier];
            }
            
            cell.textLabel.text = NSLocalizedString(@"Owner", @"");
            cell.detailTextLabel.text = self.gist.user.login;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            return cell;
        }
    } else if (indexPath.section == kUITableViewSectionFiles) {
        NSString *CellIdentifier = @"UITableViewCellWithLinearGradientBackgroundView";
        
        GHTableViewCellWithLinearGradientBackgroundView *cell = (GHTableViewCellWithLinearGradientBackgroundView *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (!cell) {
            cell = [[GHTableViewCellWithLinearGradientBackgroundView alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        }
        
        
        GHAPIGistFileV3 *file = [self.gist.files objectAtIndex:indexPath.row - 1];
        
        cell.textLabel.text = file.filename;
        cell.detailTextLabel.text = [NSString stringFormFileSize:[file.size longLongValue] ];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        return cell;
    } else if (indexPath.section == kUITableViewSectionForks) {
        NSString *CellIdentifier = @"UITableViewCellWithLinearGradientBackgroundView";
        
        GHTableViewCellWithLinearGradientBackgroundView *cell = (GHTableViewCellWithLinearGradientBackgroundView *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (!cell) {
            cell = [[GHTableViewCellWithLinearGradientBackgroundView alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        }
        
        GHAPIGistForkV3 *fork = [self.gist.forks objectAtIndex:indexPath.row - 1];
        
        cell.textLabel.text = fork.user.login;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        return cell;
    } else if (indexPath.section == kUITableViewSectionComments) {
        // comments
        if (indexPath.row >= 1 && indexPath.row <= [self.comments count]) {
            static NSString *CellIdentifier = @"GHPAttributedTableViewCell";
            GHAttributedTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            if (!cell) {
                cell = [[GHAttributedTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
            }
            // display a comment
            
            GHAPIGistCommentV3 *comment = [self.comments objectAtIndex:indexPath.row - 1];
            
            [self updateImageView:cell.imageView atIndexPath:indexPath withAvatarURLString:comment.user.avatarURL];
            
            cell.textLabel.text = comment.user.login;
            cell.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@ ago", @""), comment.createdAt.prettyTimeIntervalSinceNow];
            cell.attributedString = comment.attributedBody;
            cell.selectedAttributesString = comment.selectedAttributedBody;
            cell.buttonDelegate = self;
            
            return cell;
        } else if (indexPath.row == [self.comments count] + 1) {
            // this is the new comment button
            NSString *CellIdentifier = @"GHNewCommentTableViewCell";
            
            GHNewCommentTableViewCell *cell = (GHNewCommentTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[GHNewCommentTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            }
            
            [self updateImageView:cell.imageView atIndexPath:indexPath withAvatarURLString:[GHAPIAuthenticationManager sharedInstance].authenticatedUser.avatarURL];
            
            cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@ (right now)", @""), [GHAPIAuthenticationManager sharedInstance].authenticatedUser.login];
            cell.delegate = self;
            if (self.lastUserComment) {
                cell.textView.text = self.lastUserComment;
                self.lastUserComment = nil;
            }
            
            return cell;
        }
    }
    
    
    return self.dummyCell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == kUITableViewSectionInfo) {
        if (indexPath.row == 0) {
            return [GHDescriptionTableViewCell heightWithContent:self.gist.description];
        }
    } else if (indexPath.section == kUITableViewSectionComments) {
        if (indexPath.row >= 1 && indexPath.row <= [self.comments count]) {
            // we are going to display a comment
            return [self cachedHeightForRowAtIndexPath:indexPath];
        } else if (indexPath.row == [self.comments count] + 1) {
            return GHNewCommentTableViewCellHeight;
        }
    }
    
    return 44.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == kUITableViewSectionForks) {
        GHAPIGistForkV3 *fork = [self.gist.forks objectAtIndex:indexPath.row - 1];
        
        GHUserViewController *userViewController = [[GHUserViewController alloc] initWithUsername:fork.user.login];
        [self.navigationController pushViewController:userViewController animated:YES];
    } else if (indexPath.section == kUITableViewSectionFiles) {
        GHAPIGistFileV3 *file = [self.gist.files objectAtIndex:indexPath.row - 1];
        
        GHViewCloudFileViewController *fileViewController = [[GHViewCloudFileViewController alloc] initWithFile:file.filename contentsOfFile:file.content];
        [self.navigationController pushViewController:fileViewController animated:YES];
    } else if (indexPath.section == kUITableViewSectionComments && indexPath.row > 0 && indexPath.row <= self.comments.count) {
        GHAPIGistCommentV3 *comment = [self.comments objectAtIndex:indexPath.row - 1];
        
        GHUserViewController *userViewController = [[GHUserViewController alloc] initWithUsername:comment.user.login];
        [self.navigationController pushViewController:userViewController animated:YES];
    } else if (indexPath.section == kUITableViewSectionInfo && indexPath.row == 1) {
        GHUserViewController *userViewController = [[GHUserViewController alloc] initWithUsername:self.gist.user.login];
        [self.navigationController pushViewController:userViewController animated:YES];
    } else {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
}

#pragma mark - GHAttributedTableViewCellDelegate

- (void)attributedTableViewCell:(GHAttributedTableViewCell *)cell receivedClickForButton:(DTLinkButton *)button {
    GHWebViewViewController *viewController = [[GHWebViewViewController alloc] initWithURL:button.url ];
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - Keyed Archiving

- (void)encodeWithCoder:(NSCoder *)encoder {
    [super encodeWithCoder:encoder];
    [encoder encodeObject:_ID forKey:@"iD"];
    [encoder encodeObject:_gist forKey:@"gist"];
    [encoder encodeBool:_hasStarData forKey:@"hasStarData"];
    [encoder encodeBool:_isGistStarred forKey:@"isGistStarred"];
    [encoder encodeObject:_comments forKey:@"comments"];
    
    if (self.isViewLoaded) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.comments.count+1 inSection:kUITableViewSectionComments];
        GHNewCommentTableViewCell *cell = nil;
        @try {
            cell = (GHNewCommentTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        }
        @catch (NSException *exception) { }
        NSString *text = cell.textView.text;
        
        if (text != nil) {
            [encoder encodeObject:text forKey:@"lastUserComment"];
        }
    }
}

- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super initWithCoder:decoder])) {
        _ID = [decoder decodeObjectForKey:@"iD"];
        _gist = [decoder decodeObjectForKey:@"gist"];
        _hasStarData = [decoder decodeBoolForKey:@"hasStarData"];
        _isGistStarred = [decoder decodeBoolForKey:@"isGistStarred"];
        _comments = [decoder decodeObjectForKey:@"comments"];
        _lastUserComment = [decoder decodeObjectForKey:@"lastUserComment"];
    }
    return self;
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == kUIActionButtonActionSheetTag) {
        NSString *title = nil;
        @try {
            title = [actionSheet buttonTitleAtIndex:buttonIndex];
        }
        @catch (NSException *exception) {}
        
        if ([title isEqualToString:NSLocalizedString(@"Delete", @"")]) {
            self.actionButtonActive = YES;
            [GHAPIGistV3 deleteGistWithID:self.gist.ID 
                        completionHandler:^(NSError *error) {
                            self.actionButtonActive = NO;
                            if (error) {
                                [self handleError:error];
                            } else {
                                [[ANNotificationQueue sharedInstance] detatchSuccesNotificationWithTitle:NSLocalizedString(@"Successfully", @"") message:NSLocalizedString(@"Deleted Gist", @"")];
                                if (self.navigationController.topViewController == self) {
                                    [self.navigationController popViewControllerAnimated:YES];
                                }
                            }
                        }];
        } else if ([title isEqualToString:NSLocalizedString(@"Unstar", @"")]) {
            self.actionButtonActive = YES;
            [GHAPIGistV3 unstarGistWithID:self.gist.ID completionHandler:^(NSError *error) {
                self.actionButtonActive = NO;
                if (error) {
                    [self handleError:error];
                } else {
                    _isGistStarred = NO;
                    [[ANNotificationQueue sharedInstance] detatchSuccesNotificationWithTitle:NSLocalizedString(@"Successfully", @"") message:NSLocalizedString(@"Unstarred Gist", @"") ];
                }
            }];
        } else if ([title isEqualToString:NSLocalizedString(@"Star", @"")]) {
            self.actionButtonActive = YES;
            [GHAPIGistV3 starGistWithID:self.gist.ID completionHandler:^(NSError *error) {
                self.actionButtonActive = NO;
                if (error) {
                    [self handleError:error];
                } else {
                    _isGistStarred = YES;
                    [[ANNotificationQueue sharedInstance] detatchSuccesNotificationWithTitle:NSLocalizedString(@"Successfully", @"") message:NSLocalizedString(@"Starred Gist", @"") ];
                }
            }];
        } else if ([title isEqualToString:NSLocalizedString(@"Fork", @"")]) {
            self.actionButtonActive = YES;
            [GHAPIGistV3 forkGistWithID:self.gist.ID 
                      completionHandler:^(GHAPIGistV3 *gist, NSError *error) {
                          self.actionButtonActive = NO;
                          if (error) {
                              [self handleError:error];
                          } else {
                              [[ANNotificationQueue sharedInstance] detatchSuccesNotificationWithTitle:NSLocalizedString(@"Successfully", @"") message:NSLocalizedString(@"Forked Gist", @"") ];
                          }
                      }];
        }
    }
}

#pragma mark - GHActionButtonTableViewController

- (void)downloadDataToDisplayActionButton {
    [GHAPIGistV3 isGistStarredWithID:self.gist.ID completionHandler:^(BOOL starred, NSError *error) {
        if (error) {
            [self failedToDownloadDataToDisplayActionButtonWithError:error];
        } else {
            _hasStarData = YES;
            _isGistStarred = starred;
            [self didDownloadDataToDisplayActionButton];
        }
    }];
}

- (UIActionSheet *)actionButtonActionSheet {
    UIActionSheet *sheet = [[UIActionSheet alloc] init];
    sheet.title = [NSString stringWithFormat:@"Gist: %@", self.gist.ID];;
    NSUInteger currentButtonIndex = 0;
    
    if (self.isGistOwnedByAuthenticatedUser) {
        [sheet addButtonWithTitle:NSLocalizedString(@"Delete", @"")];
        sheet.destructiveButtonIndex = currentButtonIndex;
        currentButtonIndex++;
    } else {
        [sheet addButtonWithTitle:_isGistStarred ? NSLocalizedString(@"Unstar", @"") : NSLocalizedString(@"Star", @"")];
        currentButtonIndex++;
        
        [sheet addButtonWithTitle:NSLocalizedString(@"Fork", @"")];
        currentButtonIndex++;
    }
    
    [sheet addButtonWithTitle:NSLocalizedString(@"Cancel", @"")];
    sheet.cancelButtonIndex = currentButtonIndex;
    currentButtonIndex++;
    
    sheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    sheet.delegate = self;
    
    return sheet;
}

- (BOOL)canDisplayActionButton {
    return YES;
}

- (BOOL)needsToDownloadDataToDisplayActionButtonActionSheet {
    if (!self.isGistOwnedByAuthenticatedUser) {
        return !_hasStarData;
    }
    return NO;
}

@end
