//
//  GHDateSelectViewController.h
//  iGithub
//
//  Created by Oliver Letterer on 01.08.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KalViewController.h"

@class GHDateSelectViewController;

@protocol GHDateSelectViewControllerDelegate <NSObject>

- (void)dateSelectViewController:(GHDateSelectViewController *)viewController didSelectDate:(NSDate *)date;
- (void)dateSelectViewControllerDidCancel:(GHDateSelectViewController *)viewController;

@end



@interface GHDateSelectViewController : KalViewController {
@private
    id<GHDateSelectViewControllerDelegate> __weak _dateDelegate;
}

@property (nonatomic, weak) id<GHDateSelectViewControllerDelegate> dateDelegate;

- (void)cancelButtonClicked:(UIBarButtonItem *)sender;

@end
