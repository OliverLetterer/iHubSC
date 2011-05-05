//
//  GHGistViewController.h
//  iGithub
//
//  Created by Oliver Letterer on 05.05.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GHTableViewController.h"

@class GHGist;

@interface GHGistViewController : GHTableViewController {
@private
    NSString *_ID;
    GHGist *_gist;
    
    // star
    BOOL _hasStarData;
    BOOL _isGistStarred;
    
    NSMutableArray *_comments;
    
    UITextView *_textView;
    UIToolbar *_textViewToolBar;
}

@property (nonatomic, copy) NSString *ID;
@property (nonatomic, retain) GHGist *gist;

@property (nonatomic, retain) NSMutableArray *comments;

@property (nonatomic, retain) UITextView *textView;
@property (nonatomic, retain) UIToolbar *textViewToolBar;

- (id)initWithID:(NSString *)ID;

- (void)cacheHeightForComments;

@end
