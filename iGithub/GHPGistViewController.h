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

@interface GHPGistViewController : GHPInfoSectionTableViewController <NSCoding, GHPAttributedTableViewCellDelegate, UIActionSheetDelegate> {
@private
    NSString *_gistID;
    GHAPIGistV3 *_gist;
    
    NSMutableArray *_comments;
    
    UITextView *_textView;
    UIToolbar *_textViewToolBar;
    
    BOOL _hasStarredData;
    BOOL _isGistStarred;
    
}

@property (nonatomic, copy) NSString *gistID;
@property (nonatomic, retain) GHAPIGistV3 *gist;

@property (nonatomic, retain) NSMutableArray *comments;

- (id)initWithGistID:(NSString *)gistID;

@property (nonatomic, retain) UITextView *textView;
@property (nonatomic, retain) UIToolbar *textViewToolBar;

- (void)cacheCommentsHeights;

@end
