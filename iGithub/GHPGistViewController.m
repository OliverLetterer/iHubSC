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
#import "GHSettingsHelper.h"
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
@synthesize textView=_textView, textViewToolBar=_textViewToolBar;

#pragma mark - setters and getters

- (void)setGistID:(NSString *)gistID {
    [_gistID release], _gistID = [gistID copy];
    
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

#pragma mark - Initialization

- (id)initWithGistID:(NSString *)gistID {
    if ((self = [super initWithStyle:UITableViewStyleGrouped])) {
        // Custom initialization
        self.gistID = gistID;
    }
    return self;
}

#pragma mark - Memory management

- (void)dealloc {
    [_gistID release];
    [_gist release];
    [_comments release];
    
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

    self.textViewToolBar = [[[UIToolbar alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 44.0)] autorelease];
    self.textViewToolBar.barStyle = UIBarStyleBlackTranslucent;
    
    UIBarButtonItem *item = nil;
    NSMutableArray *items = [NSMutableArray array];
    
    item = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", @"") 
                                             style:UIBarButtonItemStyleBordered 
                                            target:self 
                                            action:@selector(toolbarCancelButtonClicked:)]
            autorelease];
    [items addObject:item];
    
    item = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace 
                                                          target:nil 
                                                          action:@selector(noAction)]
            autorelease];
    [items addObject:item];
    
    item = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Submit", @"") 
                                             style:UIBarButtonItemStyleDone 
                                            target:self 
                                            action:@selector(toolbarDoneButtonClicked:)]
            autorelease];
    [items addObject:item];
    
    self.textViewToolBar.items = items;
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    self.textView = nil;
    self.textViewToolBar = nil;
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
	return YES;
}

#pragma mark - Height caching

- (void)cacheCommentsHeights {
    DTAttributedTextView *textView = [[[DTAttributedTextView alloc] initWithFrame:CGRectZero] autorelease];
    [self.comments enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        GHAPIGistCommentV3 *comment = obj;
        CGFloat height = [GHPAttributedTableViewCell heightWithAttributedString:comment.attributedBody 
                                                           inAttributedTextView:textView];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:idx+1 inSection:kUITableViewSectionComments];
        [self cacheHeight:height forRowAtIndexPath:indexPath];
    }];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.comments.count+1 inSection:kUITableViewSectionComments];
    [self cacheHeight:GHPNewCommentTableViewCellHeight forRowAtIndexPath:indexPath];
}

#pragma mark - target actions

- (void)toolbarCancelButtonClicked:(UIBarButtonItem *)barButton {
    [self.textView resignFirstResponder];
}

- (void)toolbarDoneButtonClicked:(UIBarButtonItem *)barButton {
    [self.textView resignFirstResponder];
    
    [GHAPIGistV3 postComment:self.textView.text 
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
                   
                   self.textView.text = nil;
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
                cell = [[[GHPUserTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                                    reuseIdentifier:CellIdentifier]
                        autorelease];
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
                cell = [[[GHPNewCommentTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            }
            [self setupDefaultTableViewCell:cell forRowAtIndexPath:indexPath];
            
            [self updateImageView:cell.imageView atIndexPath:indexPath withAvatarURLString:[GHSettingsHelper avatarURL]];
            
            cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@ (right now)", @""), [GHSettingsHelper username]];
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            self.textView = cell.textView;
            cell.textView.inputAccessoryView = self.textViewToolBar;
            self.textView.scrollsToTop = NO;
            
            return cell;
        } else {
            static NSString *CellIdentifier = @"GHPAttributedTableViewCell";
            GHPAttributedTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            if (!cell) {
                cell = [[[GHPAttributedTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
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
            cell = [[[GHPDefaultTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
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
            viewController = [[[GHPUserViewController alloc] initWithUsername:self.gist.user.login] autorelease];
        }
    } else if (indexPath.section == kUITableViewSectionComments && indexPath.row <= self.comments.count) {
        GHAPIGistCommentV3 *comment = [self.comments objectAtIndex:indexPath.row -1];
        
        viewController = [[[GHPUserViewController alloc] initWithUsername:comment.user.login] autorelease];
    } else if (indexPath.section == kUITableViewSectionFiles) {
        GHAPIGistFileV3 *file = [self.gist.files objectAtIndex:indexPath.row - 1];
        
        viewController = [[[GHViewCloudFileViewController alloc] initWithFile:file.filename 
                                                               contentsOfFile:file.content] 
                          autorelease];
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
        @catch (NSException *exception) {
        }
        
        [self setActionButtonActive:YES];
        
        if ([title isEqualToString:NSLocalizedString(@"Unstar", @"")]) {
            [GHAPIGistV3 unstarGistWithID:self.gistID 
                        completionHandler:^(NSError *error) {
                            [self setActionButtonActive:NO];
                            if (error) {
                                [self handleError:error];
                            } else {
                                [[ANNotificationQueue sharedInstance] detatchSuccesNotificationWithTitle:NSLocalizedString(@"Successfully Unstarred", @"") message:[NSString stringWithFormat:NSLocalizedString(@"Gist %@", @""), self.gist.ID]];
                                _isGistStarred = NO;
                            }
                        }];
        } else if ([title isEqualToString:NSLocalizedString(@"Star", @"")]) {
            [GHAPIGistV3 starGistWithID:self.gistID 
                      completionHandler:^(NSError *error) {
                          [self setActionButtonActive:NO];
                          if (error) {
                              [self handleError:error];
                          } else {
                              [[ANNotificationQueue sharedInstance] detatchSuccesNotificationWithTitle:NSLocalizedString(@"Successfully Starred", @"") message:[NSString stringWithFormat:NSLocalizedString(@"Gist %@", @""), self.gist.ID]];
                              _isGistStarred = YES;
                          }
                      }];
        } else {
            [self setActionButtonActive:NO];
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
    UIActionSheet *sheet = [[[UIActionSheet alloc] init] autorelease];
    
    if (_isGistStarred) {
        [sheet addButtonWithTitle:NSLocalizedString(@"Unstar", @"")];
    } else {
        [sheet addButtonWithTitle:NSLocalizedString(@"Star", @"")];
    }
    
    sheet.delegate = self;
    sheet.tag = kUIActionSheetTagAction;
    
    return sheet;
}

- (BOOL)canDisplayActionButton {
    return YES;
}

- (BOOL)canDisplayActionButtonActionSheet {
    return _hasStarredData;
}

#pragma mark - GHPAttributedTableViewCellDelegate

- (void)attributedTableViewCell:(GHPAttributedTableViewCell *)cell receivedClickForButton:(DTLinkButton *)button {
    GHWebViewViewController *viewController = [[[GHWebViewViewController alloc] initWithURL:button.url ] autorelease];
    [self.advancedNavigationController pushViewController:viewController afterViewController:self animated:YES];
}

#pragma mark - Keyed Archiving

- (void)encodeWithCoder:(NSCoder *)encoder {
    [super encodeWithCoder:encoder];
    [encoder encodeObject:_gistID forKey:@"gistID"];
    [encoder encodeObject:_gist forKey:@"gist"];
    [encoder encodeObject:_comments forKey:@"comments"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super initWithCoder:decoder])) {
        _gistID = [[decoder decodeObjectForKey:@"gistID"] retain];
        _gist = [[decoder decodeObjectForKey:@"gist"] retain];
        _comments = [[decoder decodeObjectForKey:@"comments"] retain];
    }
    return self;
}

@end
