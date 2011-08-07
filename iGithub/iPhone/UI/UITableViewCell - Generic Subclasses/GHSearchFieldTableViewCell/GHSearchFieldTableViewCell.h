//
//  GHSearchFieldTableViewCell.h
//  iGithub
//
//  Created by Oliver Letterer on 03.08.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GHTableViewCell.h"

extern CGFloat const kGHSearchFieldTableViewCellHeight;

@interface GHSearchFieldTableViewCell : GHTableViewCell {
@private
    UISearchBar *_searchBar;
}

@property (nonatomic, readonly, retain) UISearchBar *searchBar;

@end
