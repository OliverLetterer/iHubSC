//
//  GHOwnerNewsFeedViewController.h
//  iGithub
//
//  Created by Oliver Letterer on 12.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GHNewsFeedViewController.h"

@interface GHOwnerNewsFeedViewController : GHNewsFeedViewController <UIActionSheetDelegate> {
@private
    UISegmentedControl *_segmentControl;
    UISegmentedControl *_stateSegmentControl;
    
    NSArray *_organizations;
    NSString *_defaultOrganizationName;
    NSString *_lastCreationDate;
    
    NSMutableArray *_pendingStateStringsArray;
    NSDate *_lastStateUpdateDate;
    
    NSUInteger _lastSelectedSegmentControlIndex;
    
    BOOL _updateScrollView;
}

@property (nonatomic, retain) UISegmentedControl *segmentControl;
@property (nonatomic, retain) UISegmentedControl *stateSegmentControl;
@property (nonatomic, retain) NSArray *organizations;
@property (nonatomic, retain) NSString *defaultOrganizationName;
@property (nonatomic, copy) NSString *lastCreationDate;
@property (nonatomic, retain) NSMutableArray *pendingStateStringsArray;
@property (nonatomic, retain) NSDate *lastStateUpdateDate;

- (void)segmentControlValueChanged:(UISegmentedControl *)segmentControl;
- (void)loadDataBasedOnSegmentControl;

- (void)displayOrganizationAtIndex:(NSUInteger)index;
- (void)showLoadingInformation:(NSString *)infoString;
- (void)didRefreshNewsFeed:(NSString *)infoString;

@end
