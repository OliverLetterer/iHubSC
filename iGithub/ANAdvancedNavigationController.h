//
//  ANAdvancedNavigationController.h
//  ANAdvancedNavigationController
//
//  Created by Oliver Letterer on 28.06.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

extern const CGFloat ANAdvancedNavigationControllerDefaultLeftViewControllerWidth;
extern const CGFloat ANAdvancedNavigationControllerDefaultViewControllerWidth;
extern const CGFloat ANAdvancedNavigationControllerDefaultLeftPanningOffset;

@interface ANAdvancedNavigationController : UIViewController

@property (nonatomic, retain) UIView *backgroundView;

- (id)initWithLeftViewController:(UIViewController *)leftViewController;
- (id)initWithLeftViewController:(UIViewController *)leftViewController rightViewControllers:(NSArray *)rightViewControllers;

- (void)pushRootViewController:(UIViewController *)rootViewController;
- (void)pushViewController:(UIViewController *)viewController afterViewController:(UIViewController *)afterViewController;
- (void)popViewController:(UIViewController *)viewController;

@end




@interface UIViewController (ANAdvancedNavigationController)
@property (nonatomic, readonly) ANAdvancedNavigationController *advancedNavigationController;
@end
