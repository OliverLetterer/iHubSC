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
    
    NSArray *_organizations;
    
    NSString *_defaultOrganizationName;
    
    NSString *_lastCreationDate;
}

@property (nonatomic, retain) UISegmentedControl *segmentControl;
@property (nonatomic, retain) NSArray *organizations;
@property (nonatomic, retain) NSString *defaultOrganizationName;
@property (nonatomic, copy) NSString *lastCreationDate;

- (void)segmentControlValueChanged:(UISegmentedControl *)segmentControl;
- (void)loadDataBasedOnSegmentControl;

- (void)displayOrganizationAtIndex:(NSUInteger)index;
- (void)showLoadingInformation:(NSString *)infoString;
- (void)didRefreshNewsFeed:(NSString *)infoString;

@end
