//
//  ANAdvancedNavigationController.h
//  ANAdvancedNavigationController
//
//  Created by Oliver Letterer on 28.06.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

//#warning removing rightViewControllers may still cause crashes while network traffic occours

extern const CGFloat ANAdvancedNavigationControllerDefaultLeftViewControllerWidth;
extern const CGFloat ANAdvancedNavigationControllerDefaultViewControllerWidth;
extern const CGFloat ANAdvancedNavigationControllerDefaultLeftPanningOffset;

@interface ANAdvancedNavigationController : UIViewController

@property (nonatomic, retain) UIView *backgroundView;
@property (nonatomic, retain) UIViewController *leftViewController;
@property (nonatomic, readonly, copy) NSArray *rightViewControllers;

- (id)initWithLeftViewController:(UIViewController *)leftViewController;
- (id)initWithLeftViewController:(UIViewController *)leftViewController rightViewControllers:(NSArray *)rightViewControllers;

- (void)popViewController:(UIViewController *)viewController animated:(BOOL)animated;
- (void)popViewControllersToViewController:(UIViewController *)viewController animated:(BOOL)animated;

- (void)pushViewController:(UIViewController *)viewController afterViewController:(UIViewController *)afterViewController animated:(BOOL)animated;

@end




@interface UIViewController (ANAdvancedNavigationController)
@property (nonatomic, readonly) ANAdvancedNavigationController *advancedNavigationController;
@end
