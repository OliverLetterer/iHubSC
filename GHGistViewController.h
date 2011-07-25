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
#import "GHNewCommentTableViewCell.h"

@class GHAPIGistV3;

#warning serialize userInputState

@interface GHGistViewController : GHTableViewController <GHAttributedTableViewCellDelegate, GHNewCommentTableViewCellDelegate> {
@private
    NSString *_ID;
    GHAPIGistV3 *_gist;
    
    // star
    BOOL _hasStarData;
    BOOL _isGistStarred;
    
    NSMutableArray *_comments;
}

@property (nonatomic, copy) NSString *ID;
@property (nonatomic, retain) GHAPIGistV3 *gist;

@property (nonatomic, retain) NSMutableArray *comments;

- (id)initWithID:(NSString *)ID;

- (void)cacheHeightForComments;

@end
