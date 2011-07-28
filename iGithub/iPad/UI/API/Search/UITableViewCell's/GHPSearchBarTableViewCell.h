//
//  GHPSearchBarTableViewCell.h
//  iGithub
//
//  Created by Oliver Letterer on 09.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GHPDefaultTableViewCell.h"

@interface GHPSearchBarTableViewCell : GHPDefaultTableViewCell {
@private
    UISearchBar *_searchBar;
}

@property (nonatomic, retain) UISearchBar *searchBar;

@end
