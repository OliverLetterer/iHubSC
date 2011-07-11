//
//  GHPLeftNavigationController.h
//  iGithub
//
//  Created by Oliver Letterer on 30.06.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GHTableViewController.h"
#import "GHPEdgedLineView.h"

@interface GHPLeftNavigationController : GHTableViewController <UIAlertViewDelegate> {
    GHPEdgedLineView *_lineView;
    UIView *_controllerView;
    
    NSIndexPath *_lastSelectedIndexPath;
}

@property (nonatomic, retain) GHPEdgedLineView *lineView;
@property (nonatomic, retain) UIView *controllerView;

@property (nonatomic, copy) NSIndexPath *lastSelectedIndexPath;

- (void)gearButtonClicked:(UIButton *)button;

@end
