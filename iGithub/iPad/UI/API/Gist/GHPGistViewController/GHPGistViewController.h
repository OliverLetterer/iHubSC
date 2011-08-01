//
//  GHPGistViewController.h
//  iGithub
//
//  Created by Oliver Letterer on 07.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GHTableViewController.h"
#import "GHPInfoTableViewCell.h"
#import "GHPInfoSectionTableViewController.h"
#import "GHPAttributedTableViewCell.h"
#import "GHPNewCommentTableViewCell.h"

@interface GHPGistViewController : GHPInfoSectionTableViewController <NSCoding, GHPAttributedTableViewCellDelegate, UIActionSheetDelegate, GHPNewCommentTableViewCellDelegate> {
@private
    NSString *_gistID;
    GHAPIGistV3 *_gist;
    
    NSMutableArray *_comments;
    
    BOOL _hasStarredData;
    BOOL _isGistStarred;
    
    NSString *_lastUserComment;
}

@property (nonatomic, readonly) BOOL isGistOwnedByAuthenticatedUser;

@property (nonatomic, copy) NSString *gistID;
@property (nonatomic, retain) GHAPIGistV3 *gist;

@property (nonatomic, retain) NSMutableArray *comments;
@property (nonatomic, copy) NSString *lastUserComment;

- (id)initWithGistID:(NSString *)gistID;

- (void)cacheCommentsHeights;

@end
