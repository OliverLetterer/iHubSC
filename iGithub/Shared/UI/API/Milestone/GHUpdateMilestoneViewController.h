//
//  GHUpdateMilestoneViewController.h
//  iGithub
//
//  Created by Oliver Letterer on 01.08.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GHCreateMilestoneViewController.h"

@interface GHUpdateMilestoneViewController : GHCreateMilestoneViewController {
@private
    GHAPIMilestoneV3 *_milestone;
    
    BOOL _didUpdateFirstCell;
}

@property (nonatomic, retain) GHAPIMilestoneV3 *milestone;

- (id)initWithMilestone:(GHAPIMilestoneV3 *)milestone repository:(NSString *)repository;

@end
