//
//  GHPSearchViewController.h
//  iGithub
//
//  Created by Oliver Letterer on 09.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GHTableViewController.h"
#import "GHPSearchScopeTableViewCell.h"

typedef enum {
    GHPSearchViewControllerDataTypeNone = 0,
    GHPSearchViewControllerDataTypeRepositories = 1,
    GHPSearchViewControllerDataTypeUsers = 2
} GHPSearchViewControllerDataType;

@interface GHPSearchViewController : GHTableViewController <UISearchBarDelegate, UISearchDisplayDelegate, GHPSearchScopeTableViewCellDelegate> {
@private
    GHPSearchViewControllerDataType _dataType;
    NSMutableArray *_dataArray;
    
    GHPSearchViewControllerDataType _nextSearchType;
    
    GHPSearchScopeTableViewCell *_searchScopeTableViewCell;
    
    UISearchDisplayController *_mySearchDisplayController;
}

- (void)downloadDataBasedOnSearchString;

@property (nonatomic, readonly) GHPSearchViewControllerDataType dataType;
@property (nonatomic, retain, readonly) NSMutableArray *dataArray;
- (void)setDataArray:(NSMutableArray *)dataArray withDataType:(GHPSearchViewControllerDataType)dataType;

@property (nonatomic, retain) GHPSearchScopeTableViewCell *searchScopeTableViewCell;

@end
