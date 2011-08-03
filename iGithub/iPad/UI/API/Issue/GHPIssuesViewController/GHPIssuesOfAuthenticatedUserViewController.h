//
//  GHPIssuesOfAuthenticatedUserViewController.h
//  iGithub
//
//  Created by Oliver Letterer on 14.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GHPIssuesViewController.h"

@interface GHPIssuesOfAuthenticatedUserViewController : GHPIssuesViewController <UISearchBarDelegate, UISearchDisplayDelegate, NSCoding> {
@private
    NSString *_searchString;
    NSMutableArray *_filteresIssues;
    
    UISearchBar *_searchBar;
    UISearchDisplayController *_mySearchDisplayController;
    
    BOOL _isSearchBarActive;
}

@property (nonatomic, copy) NSString *searchString;
@property (nonatomic, retain) NSMutableArray *filteresIssues;

@end
