//
//  GHPMileStonesTableViewController.h
//  iGithub
//
//  Created by Oliver Letterer on 05.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GHTableViewController.h"


@interface GHPMileStonesTableViewController : GHTableViewController {
@private
    NSMutableArray *_milestones;
    
    NSString *_repository;
}

@property (nonatomic, retain) NSMutableArray *milestones;

@property (nonatomic, copy) NSString *repository;

- (id)initWithRepository:(NSString *)repository;

@end
