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
#import "GHSettingsHelper.h"

#define kUITableViewSectionInfo 0
#define kUITableViewSectionFiles 1
#define kUITableViewSectionForks 2
#define kUITableViewSectionComments 3
#define kUITableViewSectionStar 4

#define kUITableViewSections 5

@implementation GHGistViewController

@synthesize ID=_ID, gist=_gist, comments=_comments;
@synthesize textView=_textView, textViewToolBar=_textViewToolBar;

#pragma mark - setters and getters

- (void)setID:(NSString *)ID {
    [_ID release];
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

#pragma mark - Initialization

- (id)initWithID:(NSString *)ID {
    if ((self = [super initWithStyle:UITableViewStylePlain])) {
        // Custom initialization
        self.ID = ID;
        self.title = NSLocalizedString(@"Gist", @"");
    }
    return self;
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
              [self cacheHeightForComments];
              
              [self.tableView beginUpdates];
              
              [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:[self.comments count]+1 inSection:kUITableViewSectionComments]] withRowAnimation:UITableViewRowAnimationFade];
              [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:[self.comments count] inSection:kUITableViewSectionComments]] withRowAnimation:UITableViewRowAnimationFade];
              
              [self.tableView endUpdates];
              
              self.textView.text = nil;
          }
      }];
}

#pragma mark - Memory management

- (void)dealloc {
    [_ID release];
    [_gist release];
    [_comments release];
    [_textView release];
    [_textViewToolBar release];
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
 - (void)loadView {
 
 }
 */

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
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - instance methods

- (void)cacheHeightForComments {
    [self.comments enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        GHAPIGistCommentV3 *comment = obj;
        
        CGFloat height = [self heightForDescription:comment.body] + 50.0;
        
        if (height < 71.0) {
            height = 71.0;
        }
        
        [self cacheHeight:height forRowAtIndexPath:[NSIndexPath indexPathForRow:idx+1 inSection:kUITableViewSectionComments]];
    }];
}

#pragma mark - UIExpandableTableViewDatasource

- (BOOL)tableView:(UIExpandableTableView *)tableView canExpandSection:(NSInteger)section {
    return section == kUITableViewSectionFiles || section == kUITableViewSectionForks || section == kUITableViewSectionStar || section == kUITableViewSectionComments;
}

- (BOOL)tableView:(UIExpandableTableView *)tableView needsToDownloadDataForExpandableSection:(NSInteger)section {
    if (section == kUITableViewSectionStar) {
        return !_hasStarData;
    } else if (section == kUITableViewSectionComments) {
        return self.comments == nil;
    }
    return NO;
}

- (UITableViewCell<UIExpandingTableViewCell> *)tableView:(UIExpandableTableView *)tableView expandingCellForSection:(NSInteger)section {
    NSString *CellIdientifier = @"UICollapsingAndSpinningTableViewCell";
    
    GHCollapsingAndSpinningTableViewCell *cell = (GHCollapsingAndSpinningTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdientifier];
    
    if (cell == nil) {
        cell = [[[GHCollapsingAndSpinningTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdientifier] autorelease];
    }
    
    if (section == kUITableViewSectionFiles) {
        cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Files (%d)", @""), self.gist.files.count ];
    } else if (section == kUITableViewSectionForks) {
        cell.textLabel.text = NSLocalizedString(@"Forked by", @"");
    } else if (section == kUITableViewSectionStar) {
        if (!_hasStarData) {
            cell.textLabel.text = NSLocalizedString(@"Star", @"");
        } else {
            if (_isGistStarred) {
                cell.textLabel.text = NSLocalizedString(@"Starred", @"");
            } else {
                cell.textLabel.text = NSLocalizedString(@"Unstarred", @"");
            }
        }
    } else if (section == kUITableViewSectionComments) {
        cell.textLabel.text = NSLocalizedString(@"Comments", @"");
    }
    
    return cell;
}

#pragma mark - UIExpandableTableViewDelegate

- (void)tableView:(UIExpandableTableView *)tableView downloadDataForExpandableSection:(NSInteger)section {
    if (section == kUITableViewSectionStar) {
        [GHAPIGistV3 isGistStarredWithID:self.gist.ID completionHandler:^(BOOL starred, NSError *error) {
            if (error) {
                [self handleError:error];
                [tableView cancelDownloadInSection:section];
            } else {
                _hasStarData = YES;
                _isGistStarred = starred;
                [tableView expandSection:section animated:YES];
            }
        }];
    } else if (section == kUITableViewSectionComments) {
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
    } else if (section == kUITableViewSectionStar) {
        return 2;
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
                cell = [[[GHDescriptionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
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
                cell = [[[GHTableViewCellWithLinearGradientBackgroundView alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier] autorelease];
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
            cell = [[[GHTableViewCellWithLinearGradientBackgroundView alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
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
            cell = [[[GHTableViewCellWithLinearGradientBackgroundView alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        }
        
        GHAPIGistForkV3 *fork = [self.gist.forks objectAtIndex:indexPath.row - 1];
        
        cell.textLabel.text = fork.user.login;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        return cell;
    } else if (indexPath.section == kUITableViewSectionStar) {
        if (indexPath.row == 1) {
            NSString *CellIdentifier = @"UITableViewCellWithLinearGradientBackgroundViewStar";
            
            GHTableViewCellWithLinearGradientBackgroundView *cell = (GHTableViewCellWithLinearGradientBackgroundView *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (!cell) {
                cell = [[[GHTableViewCellWithLinearGradientBackgroundView alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
            }
            
            cell.textLabel.text = _isGistStarred ? NSLocalizedString(@"Unstar", @"") : NSLocalizedString(@"Star", @"");
            cell.accessoryType = UITableViewCellAccessoryNone;
            
            return cell;
        }
    } else if (indexPath.section == kUITableViewSectionComments) {
        // comments
        if (indexPath.row >= 1 && indexPath.row <= [self.comments count]) {
            // display a comment
            
            NSString *CellIdentifier = @"GHFeedItemWithDescriptionTableViewCell";
            
            GHDescriptionTableViewCell *cell = (GHDescriptionTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[[GHDescriptionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            }
            
            GHAPIGistCommentV3 *comment = [self.comments objectAtIndex:indexPath.row - 1];
            
            [self updateImageView:cell.imageView atIndexPath:indexPath withAvatarURLString:comment.user.avatarURL];
            
            cell.textLabel.text = comment.user.login;
            cell.descriptionLabel.text = comment.body;
            cell.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@ ago", @""), comment.createdAt.prettyTimeIntervalSinceNow];
            
            return cell;
        } else if (indexPath.row == [self.comments count] + 1) {
            // this is the new comment button
            NSString *CellIdentifier = @"GHNewCommentTableViewCell";
            
            GHNewCommentTableViewCell *cell = (GHNewCommentTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[[GHNewCommentTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            }
            
            [self updateImageView:cell.imageView atIndexPath:indexPath withAvatarURLString:[GHSettingsHelper avatarURL]];
            
            cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@ (right now)", @""), [GHSettingsHelper username]];
            
            self.textView = cell.textView;
            cell.textView.inputAccessoryView = self.textViewToolBar;
            self.textView.scrollsToTop = NO;
            
            return cell;
        }
    }
    
    
    return self.dummyCell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == kUITableViewSectionInfo) {
        if (indexPath.row == 0) {
            CGFloat height = [self heightForDescription:self.gist.description] + 50.0;
            
            if (height < 71.0) {
                height = 71.0;
            }
            
            return height;
        }
    } else if (indexPath.section == kUITableViewSectionComments) {
        if (indexPath.row >= 1 && indexPath.row <= [self.comments count]) {
            // we are going to display a comment
            return [self cachedHeightForRowAtIndexPath:indexPath];
        } else if (indexPath.row == [self.comments count] + 1) {
            return 161.0;
        }
    }
    
    return 44.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == kUITableViewSectionForks) {
        GHAPIGistForkV3 *fork = [self.gist.forks objectAtIndex:indexPath.row - 1];
        
        GHUserViewController *userViewController = [[[GHUserViewController alloc] initWithUsername:fork.user.login] autorelease];
        [self.navigationController pushViewController:userViewController animated:YES];
    } else if (indexPath.section == kUITableViewSectionFiles) {
        GHAPIGistFileV3 *file = [self.gist.files objectAtIndex:indexPath.row - 1];
        
        GHViewCloudFileViewController *fileViewController = [[[GHViewCloudFileViewController alloc] initWithFile:file.filename contentsOfFile:file.content] autorelease];
        [self.navigationController pushViewController:fileViewController animated:YES];
    } else if (indexPath.section == kUITableViewSectionStar && indexPath.row == 1) {
        if (_isGistStarred) {
            [GHAPIGistV3 unstarGistWithID:self.gist.ID completionHandler:^(NSError *error) {
                if (error) {
                    [self handleError:error];
                } else {
                    _isGistStarred = NO;
                }
                [tableView reloadSections:[NSIndexSet indexSetWithIndex:kUITableViewSectionStar] 
                         withRowAnimation:UITableViewRowAnimationNone];
            }];
        } else {
            [GHAPIGistV3 starGistWithID:self.gist.ID completionHandler:^(NSError *error) {
                if (error) {
                    [self handleError:error];
                } else {
                    _isGistStarred = YES;
                }
                [tableView reloadSections:[NSIndexSet indexSetWithIndex:kUITableViewSectionStar] 
                         withRowAnimation:UITableViewRowAnimationNone];
            }];
        }
    } else if (indexPath.section == kUITableViewSectionComments && indexPath.row > 0 && indexPath.row <= self.comments.count) {
        GHAPIGistCommentV3 *comment = [self.comments objectAtIndex:indexPath.row - 1];
        
        GHUserViewController *userViewController = [[[GHUserViewController alloc] initWithUsername:comment.user.login] autorelease];
        [self.navigationController pushViewController:userViewController animated:YES];
    } else if (indexPath.section == kUITableViewSectionInfo && indexPath.row == 1) {
        GHUserViewController *userViewController = [[[GHUserViewController alloc] initWithUsername:self.gist.user.login] autorelease];
        [self.navigationController pushViewController:userViewController animated:YES];
    } else {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
}

#pragma mark Keyed Archiving

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:_ID forKey:@"iD"];
    [encoder encodeObject:_gist forKey:@"gist"];
    [encoder encodeBool:_hasStarData forKey:@"hasStarData"];
    [encoder encodeBool:_isGistStarred forKey:@"isGistStarred"];
    [encoder encodeObject:_comments forKey:@"comments"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super initWithCoder:decoder])) {
        _ID = [[decoder decodeObjectForKey:@"iD"] retain];
        _gist = [[decoder decodeObjectForKey:@"gist"] retain];
        _hasStarData = [decoder decodeBoolForKey:@"hasStarData"];
        _isGistStarred = [decoder decodeBoolForKey:@"isGistStarred"];
        _comments = [[decoder decodeObjectForKey:@"comments"] retain];
    }
    return self;
}

@end
