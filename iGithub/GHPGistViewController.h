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

#warning serialize userInputState

@interface GHPGistViewController : GHPInfoSectionTableViewController <NSCoding, GHPAttributedTableViewCellDelegate, UIActionSheetDelegate, GHPNewCommentTableViewCellDelegate> {
@private
    NSString *_gistID;
    GHAPIGistV3 *_gist;
    
    NSMutableArray *_comments;
    
    BOOL _hasStarredData;
    BOOL _isGistStarred;
    
}

@property (nonatomic, copy) NSString *gistID;
@property (nonatomic, retain) GHAPIGistV3 *gist;

@property (nonatomic, retain) NSMutableArray *comments;

- (id)initWithGistID:(NSString *)gistID;

- (void)cacheCommentsHeights;

@end
