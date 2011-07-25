//
//  GHGistViewController.h
//  iGithub
//
//  Created by Oliver Letterer on 05.05.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GHTableViewController.h"
#import "GHAttributedTableViewCell.h"

@class GHAPIGistV3;

@interface GHGistViewController : GHTableViewController <GHAttributedTableViewCellDelegate, UIActionSheetDelegate> {
@private
    NSString *_ID;
    GHAPIGistV3 *_gist;
    
    // star
    BOOL _hasStarData;
    BOOL _isGistStarred;
    
    NSMutableArray *_comments;
    
    UITextView *_textView;
    UIToolbar *_textViewToolBar;
    
    NSURL *_selectedURL;
}

@property (nonatomic, copy) NSString *ID;
@property (nonatomic, retain) GHAPIGistV3 *gist;

@property (nonatomic, retain) NSMutableArray *comments;

@property (nonatomic, retain) UITextView *textView;
@property (nonatomic, retain) UIToolbar *textViewToolBar;

@property (nonatomic, copy) NSURL *selectedURL;

- (id)initWithID:(NSString *)ID;

- (void)cacheHeightForComments;

@end
