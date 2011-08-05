//
//  GHPGistViewController.m
//  iGithub
//
//  Created by Oliver Letterer on 07.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHPGistViewController.h"
#import "GHPUserTableViewCell.h"
#import "GHPUserViewController.h"
#import "GHPNewCommentTableViewCell.h"
#import "NSString+Additions.h"
#import "GHViewCloudFileViewController.h"
#import "ANNotificationQueue.h"
#import "GHPAttributedTableViewCell.h"
#import "GHWebViewViewController.h"

#define kUIActionSheetTagAction             172634

#define kUITableViewSectionInfo         0
#define kUITableViewSectionOwner        1
#define kUITableViewSectionComments     2
#define kUITableViewSectionFiles        3

#define kUITableViewNumberOfSections    4

@implementation GHPGistViewController

@synthesize gistID=_gistID, gist=_gist;
@synthesize comments=_comments;
@synthesize lastUserComment=_lastUserComment;

#pragma mark - setters and getters

- (void)setGistID:(NSString *)gistID {
    _gistID = [gistID copy];
    
    self.isDownloadingEssentialData = YES;
    [GHAPIGistV3 gistWithID:_gistID 
          completionHandler:^(GHAPIGistV3 *gist, NSError *error) {
              self.isDownloadingEssentialData = NO;
              if (error) {
                  [self handleError:error];
              } else {
                  self.gist = gist;
                  if (self.isViewLoaded) {
                      [self.tableView reloadData];
                  }
              }
          }];
}

- (BOOL)isGistOwnedByAuthenticatedUser {
    return [[GHAPIAuthenticationManager sharedInstance].authenticatedUser isEqualToUser:self.gist.user];
}

#pragma mark - Initialization

- (id)initWithGistID:(NSString *)gistID {
    if ((self = [super initWithStyle:UITableViewStyleGrouped])) {
        // Custom initialization
        self.gistID = gistID;
    }
    return self;
}

#pragma mark - Height caching

- (void)cacheCommentsHeights {
    [self.comments enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        GHAPIGistCommentV3 *comment = obj;
        CGFloat height = [GHPAttributedTableViewCell heightWithAttributedString:comment.attributedBody];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:idx+1 inSection:kUITableViewSectionComments];
        [self cacheHeight:height forRowAtIndexPath:indexPath];
    }];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.comments.count+1 inSection:kUITableViewSectionComments];
    [self cacheHeight:GHPNewCommentTableViewCellHeight forRowAtIndexPath:indexPath];
}

#pragma mark - GHPNewCommentTableViewCellDelegate

- (void)newCommentTableViewCell:(GHPNewCommentTableViewCell *)cell didEnterText:(NSString *)text {
    UITextView *textView = cell.textView;
    [textView resignFirstResponder];
    
    [GHAPIGistV3 postComment:textView.text 
               forGistWithID:self.gist.ID 
           completionHandler:^(GHAPIGistCommentV3 *comment, NSError *error) {
               if (error) {
                   [self handleError:error];
               } else {
                   [self.comments addObject:comment];
                   [self cacheCommentsHeights];
                   
                   [self.tableView beginUpdates];
                   
                   [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:[self.comments count]+1 inSection:kUITableViewSectionComments]] withRowAnimation:UITableViewRowAnimationFade];
                   [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:[self.comments count] inSection:kUITableViewSectionComments]] withRowAnimation:UITableViewRowAnimationFade];
                   
                   [self.tableView endUpdates];
                   
                   textView.text = nil;
               }
           }];
}

#pragma mark - UIExpandableTableViewDatasource

- (BOOL)tableView:(UIExpandableTableView *)tableView canExpandSection:(NSInteger)section {
    return section == kUITableViewSectionComments || section == kUITableViewSectionFiles;
}

- (BOOL)tableView:(UIExpandableTableView *)tableView needsToDownloadDataForExpandableSection:(NSInteger)section {
    if (section == kUITableViewSectionComments) {
        return self.comments == nil;
    }
    return NO;
}

- (UITableViewCell<UIExpandingTableViewCell> *)tableView:(UIExpandableTableView *)tableView expandingCellForSection:(NSInteger)section {
    GHPCollapsingAndSpinningTableViewCell *cell = [self defaultPadCollapsingAndSpinningTableViewCellForSection:section];
    
    if (section == kUITableViewSectionComments) {
        cell.textLabel.text = NSLocalizedString(@"Comments", @"");
    } else if (section == kUITableViewSectionFiles) {
        cell.textLabel.text = NSLocalizedString(@"Files", @"");
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
                [self cacheCommentsHeights];
                [tableView expandSection:section animated:YES];
            }
        }];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (!self.gist) {
        return 0;
    }
    // Return the number of sections.
    return kUITableViewNumberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case kUITableViewSectionInfo:
            return 1;
            break;
        case kUITableViewSectionOwner:
            return 1;
            break;
        case kUITableViewSectionComments:
            return self.comments.count+2;
        case kUITableViewSectionFiles:
            return self.gist.files.count+1;
            break;
        default:
            break;
    }
    // Return the number of rows in the section.
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == kUITableViewSectionInfo) {
        if (indexPath.row == 0) {
            GHPInfoTableViewCell *cell = self.infoCell;
            
            GHAPIGistV3 *gist = self.gist;
            
            cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Gist: %@ (created %@ ago)", @""), gist.ID, gist.createdAt.prettyTimeIntervalSinceNow];
            
            cell.detailTextLabel.text = gist.description;
            
            if ([gist.public boolValue]) {
                cell.imageView.image = [UIImage imageNamed:@"GHClipBoard.png"];
            } else {
                cell.imageView.image = [UIImage imageNamed:@"GHClipBoardPrivate.png"];
            }
            
            return cell;
        }
    } else if (indexPath.section == kUITableViewSectionOwner) {
        if (indexPath.row == 0) {
            static NSString *CellIdentifier = @"GHPUserTableViewCell";
            GHPUserTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (!cell) {
                cell = [[GHPUserTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                                    reuseIdentifier:CellIdentifier];
            }
            
            [self setupDefaultTableViewCell:cell forRowAtIndexPath:indexPath];
            
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            [self updateImageView:cell.imageView atIndexPath:indexPath withAvatarURLString:self.gist.user.avatarURL];
            cell.textLabel.text = self.gist.user.login;
            
            return cell;
        }
    } else if (indexPath.section == kUITableViewSectionComments) {
        if (indexPath.row == [self.comments count] + 1) {
            // this is the new comment cell
            static NSString *CellIdentifier = @"GHPNewCommentTableViewCell";
            
            GHPNewCommentTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[GHPNewCommentTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            }
            [self setupDefaultTableViewCell:cell forRowAtIndexPath:indexPath];
            
            [self updateImageView:cell.imageView atIndexPath:indexPath withAvatarURLString:[GHAPIAuthenticationManager sharedInstance].authenticatedUser.avatarURL];
            
            cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@ (right now)", @""), [GHAPIAuthenticationManager sharedInstance].authenticatedUser.login];
            cell.delegate = self;
            if (self.lastUserComment) {
                cell.textView.text = self.lastUserComment;
                self.lastUserComment = nil;
            }
            
            return cell;
        } else {
            static NSString *CellIdentifier = @"GHPAttributedTableViewCell";
            GHPAttributedTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            if (!cell) {
                cell = [[GHPAttributedTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
            }
            [self setupDefaultTableViewCell:cell forRowAtIndexPath:indexPath];
            
            GHAPIGistCommentV3 *comment = [self.comments objectAtIndex:indexPath.row - 1];
            
            [self updateImageView:cell.imageView atIndexPath:indexPath withAvatarURLString:comment.user.avatarURL];
            
            cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@ (%@ ago)", @""), comment.user.login, comment.createdAt.prettyTimeIntervalSinceNow];
            cell.attributedTextView.attributedString = comment.attributedBody;
            cell.buttonDelegate = self;
            
            return cell;
        }
    } else if (indexPath.section == kUITableViewSectionFiles) {
        static NSString *CellIdentifier = @"GHPDefaultTableViewCellkUITableViewSectionFiles";
        
        GHPDefaultTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (!cell) {
            cell = [[GHPDefaultTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        }
        [self setupDefaultTableViewCell:cell forRowAtIndexPath:indexPath];
        
        GHAPIGistFileV3 *file = [self.gist.files objectAtIndex:indexPath.row - 1];
        
        cell.textLabel.text = file.filename;
        cell.detailTextLabel.text = [NSString stringFormFileSize:[file.size longLongValue] ];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        return cell;
    }
    
    return self.dummyCell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == kUITableViewSectionInfo) {
        if (indexPath.row == 0) {
            return [GHPInfoTableViewCell heightWithContent:self.gist.description];
        }
    } else if (indexPath.section == kUITableViewSectionOwner) {
        if (indexPath.row == 0) {
            return GHPUserTableViewCellHeight;
        }
    } else if (indexPath.section == kUITableViewSectionComments && indexPath.row > 0) {
        return [self cachedHeightForRowAtIndexPath:indexPath];
    }
    return UITableViewAutomaticDimension;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIViewController *viewController = nil;
    
    if (indexPath.section == kUITableViewSectionOwner) {
        if (indexPath.row == 0) {
            viewController = [[GHPUserViewController alloc] initWithUsername:self.gist.user.login];
        }
    } else if (indexPath.section == kUITableViewSectionComments && indexPath.row <= self.comments.count) {
        GHAPIGistCommentV3 *comment = [self.comments objectAtIndex:indexPath.row -1];
        
        viewController = [[GHPUserViewController alloc] initWithUsername:comment.user.login];
    } else if (indexPath.section == kUITableViewSectionFiles) {
        GHAPIGistFileV3 *file = [self.gist.files objectAtIndex:indexPath.row - 1];
        
        viewController = [[GHViewCloudFileViewController alloc] initWithFile:file.filename 
                                                               contentsOfFile:file.content];
    }
    
    if (viewController) {
        [self.advancedNavigationController pushViewController:viewController afterViewController:self animated:YES];
    } else {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == kUIActionSheetTagAction) {
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
                                [self.advancedNavigationController popViewController:self animated:YES];
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

#pragma mark - ActionMenu

- (void)downloadDataToDisplayActionButton {
    [GHAPIGistV3 isGistStarredWithID:self.gistID 
                   completionHandler:^(BOOL starred, NSError *error) {
                       if (error) {
                           [self failedToDownloadDataToDisplayActionButtonWithError:error];
                       } else {
                           _hasStarredData = YES;
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
    
    sheet.delegate = self;
    sheet.tag = kUIActionSheetTagAction;
    
    return sheet;
}

- (BOOL)canDisplayActionButton {
    return YES;
}

- (BOOL)needsToDownloadDataToDisplayActionButtonActionSheet {
    if (!self.isGistOwnedByAuthenticatedUser) {
        return !_hasStarredData;
    }
    return NO;
}

#pragma mark - GHPAttributedTableViewCellDelegate

- (void)attributedTableViewCell:(GHPAttributedTableViewCell *)cell receivedClickForButton:(DTLinkButton *)button {
    UIViewController *viewController = [[GHWebViewViewController alloc] initWithURL:button.url ];
    viewController = [[UINavigationController alloc] initWithRootViewController:viewController];
    [self.advancedNavigationController pushViewController:viewController afterViewController:self animated:YES];
}

#pragma mark - Keyed Archiving

- (void)encodeWithCoder:(NSCoder *)encoder {
    [super encodeWithCoder:encoder];
    [encoder encodeObject:_gistID forKey:@"gistID"];
    [encoder encodeObject:_gist forKey:@"gist"];
    [encoder encodeObject:_comments forKey:@"comments"];
    
    if (self.isViewLoaded) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.comments.count+1 inSection:kUITableViewSectionComments];
        GHPNewCommentTableViewCell *cell = nil;
        @try {
            cell = (GHPNewCommentTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
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
        _gistID = [decoder decodeObjectForKey:@"gistID"];
        _gist = [decoder decodeObjectForKey:@"gist"];
        _comments = [decoder decodeObjectForKey:@"comments"];
        _lastUserComment = [decoder decodeObjectForKey:@"lastUserComment"];
    }
    return self;
}

@end
