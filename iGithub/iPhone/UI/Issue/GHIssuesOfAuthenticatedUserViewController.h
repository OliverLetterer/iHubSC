//
//  GHIssuesOfAuthenticatedUserViewController.h
//  iGithub
//
//  Created by Oliver Letterer on 03.08.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GHTableViewController.h"

@interface GHIssuesOfAuthenticatedUserViewController : GHTableViewController <UISearchDisplayDelegate, UISearchBarDelegate, NSCoding> {
@private
    NSMutableArray *_assignedIssues;
    NSString *_searchString;
    NSMutableArray *_filteresIssues;
    
    UISearchBar *_searchBar;
    UISearchDisplayController *_mySearchDisplayController;
    
    BOOL _isSearchBarActive;
    BOOL _canTrackSearchBarState;
}

@property (nonatomic, retain) NSMutableArray *assignedIssues;
@property (nonatomic, copy) NSString *searchString;
@property (nonatomic, retain) NSMutableArray *filteresIssues;


- (NSString *)descriptionForAssignedIssue:(GHAPIIssueV3 *)issue;
- (void)cacheAssignedIssuesHeight;

@end
