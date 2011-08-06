//
//  GHCreateMilestoneViewController.h
//  iGithub
//
//  Created by Oliver Letterer on 01.08.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GHCreateContentViewController.h"
#import "GHDateSelectViewController.h"

@class GHCreateMilestoneViewController;

@protocol GHCreateMilestoneViewControllerDelegate <NSObject>

- (void)createMilestoneViewController:(GHCreateMilestoneViewController *)createViewController didCreateMilestone:(GHAPIMilestoneV3 *)milestone;
- (void)createMilestoneViewControllerDidCancel:(GHCreateMilestoneViewController *)createViewController;

@end


extern NSInteger const kGHCreateMilestoneViewControllerTableViewSectionTitleAndDescription;
extern NSInteger const kGHCreateMilestoneViewControllerTableViewSectionDueDate;


@interface GHCreateMilestoneViewController : GHCreateContentViewController <GHDateSelectViewControllerDelegate> {
@private
    id<GHCreateMilestoneViewControllerDelegate> __weak _delegate;
    NSString *_repository;
    
    NSDate *_selectedDueDate;
}

@property (nonatomic, weak) id<GHCreateMilestoneViewControllerDelegate> delegate;
@property (nonatomic, copy) NSString *repository;

@property (nonatomic, retain) NSDate *selectedDueDate;

- (id)initWithRepository:(NSString *)repository;

@end
