//
//  GHViewController.h
//  iGithub
//
//  Created by Oliver Letterer on 20.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ANAdvancedNavigationController.h"

@interface GHViewController : UIViewController <NSCoding> {
@private
    UIColor *_navigationTintColor;

    BOOL _presentedInPopoverController;
}

@property (nonatomic, assign, getter = isPresentedInPopoverController) BOOL presentedInPopoverController;

@property (nonatomic, retain) UIColor *navigationTintColor;

@property (nonatomic, readonly) UIView *tableHeaderShadowView;
@property (nonatomic, readonly) UIView *tableFooterShadowView;

@end
