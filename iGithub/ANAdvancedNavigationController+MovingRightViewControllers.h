//
//  ANAdvancedNavigationController+MovingRightViewControllers.h
//  ANAdvancedNavigationController
//
//  Created by Oliver Letterer on 28.06.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ANAdvancedNavigationController.h"

@interface ANAdvancedNavigationController (ANAdvancedNavigationController_MovingRightViewControllers)

- (void)mainPanGestureRecognizedDidRecognizePanGesture:(UIPanGestureRecognizer *)panGestureRecognizer;
- (void)prepareViewForPanning;

- (UIView *)viewForRightViewController:(UIViewController *)rightViewController;
- (UIView *)viewForExistingRightViewController:(UIViewController *)rightViewController;

- (void)_removeRightViewController:(UIViewController *)rightViewController animated:(BOOL)animated;

- (void)removeRightViewController:(UIViewController *)rightViewController;
- (void)removeRightViewControllerView:(UIViewController *)rightViewController animated:(BOOL)animated;
- (void)updateViewControllersWithTranslation:(CGFloat)translation;
- (void)addRightViewController:(UIViewController *)rightViewController;

- (void)loadRightViewControllers;

- (void)updateViewControllersShadow:(UIViewController *)rightViewController;

- (void)numberOfRightViewControllersChanged;

- (void)popViewControllersExceptFirst;

// views can be dragged over this point
@property (nonatomic, readonly) CGFloat leftBoundsPanningAnchor;

// anchor points, at which the viewControllers views center will be layed out
@property (nonatomic, readonly) CGFloat anchorPortraitLeft;
@property (nonatomic, readonly) CGFloat anchorPortraitRight;
@property (nonatomic, readonly) CGFloat anchorLandscapeLeft;
@property (nonatomic, readonly) CGFloat anchorLandscapeMiddle;
@property (nonatomic, readonly) CGFloat anchorLandscapeRight;
@property (nonatomic, readonly) CGFloat leftAnchorForInterfaceOrientation;
@property (nonatomic, readonly) CGFloat rightAnchorForInterfaceOrientation;
- (CGFloat)leftAnchorForInterfaceOrientationAndRightViewController:(UIViewController *)rightViewController;

@property (nonatomic, readonly) CGFloat minimumDragOffsetToShowRemoveInformation;

- (UIViewController *)bestRightAnchorPointViewControllerWithIndex:(NSInteger *)index;
- (void)moveRightViewControllerToRightAnchorPoint:(UIViewController *)rightViewController animated:(BOOL)animated;

@end
