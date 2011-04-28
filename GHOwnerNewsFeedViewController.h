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
}

@property (nonatomic, retain) UISegmentedControl *segmentControl;
@property (nonatomic, retain) NSArray *organizations;
@property (nonatomic, retain) NSString *defaultOrganizationName;

- (void)segmentControlValueChanged:(UISegmentedControl *)segmentControl;
- (void)loadDataBasedOnSegmentControl;

@end
