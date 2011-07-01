//
//  ANAdvancedNavigationController+MovingRightViewControllers.m
//  ANAdvancedNavigationController
//
//  Created by Oliver Letterer on 28.06.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ANAdvancedNavigationController+MovingRightViewControllers.h"
#import "ANAdvancedNavigationController.h"
#import "ANAdvancedNavigationController+private.h"
#import <QuartzCore/QuartzCore.h>

@implementation ANAdvancedNavigationController (ANAdvancedNavigationController_MovingRightViewControllers)

#pragma mark - setters and getters

- (CGFloat)leftBoundsPanningAnchor {
    // if we only have one viewController, we can pan infinite
    if (self.viewControllers.count <= 1) {
        return -CGFLOAT_MAX;
    }
    return ANAdvancedNavigationControllerDefaultLeftPanningOffset + ANAdvancedNavigationControllerDefaultViewControllerWidth/2.0f;
}

- (CGFloat)anchorPortraitLeft {
    return ANAdvancedNavigationControllerDefaultLeftPanningOffset + ANAdvancedNavigationControllerDefaultViewControllerWidth/2.0f;
}

- (CGFloat)anchorPortraitRight {
    return CGRectGetWidth(self.view.bounds) - ANAdvancedNavigationControllerDefaultViewControllerWidth/2.0f;
}

- (CGFloat)anchorLandscapeLeft {
    return ANAdvancedNavigationControllerDefaultLeftPanningOffset + ANAdvancedNavigationControllerDefaultViewControllerWidth/2.0f;
}

- (CGFloat)anchorLandscapeMiddle {
    return ANAdvancedNavigationControllerDefaultLeftViewControllerWidth + ANAdvancedNavigationControllerDefaultViewControllerWidth/2.0f;
}

- (CGFloat)anchorLandscapeRight {
    return CGRectGetWidth(self.view.bounds) - ANAdvancedNavigationControllerDefaultViewControllerWidth/2.0f;
}

- (CGFloat)leftAnchorForInterfaceOrientation {
    if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
        return self.anchorPortraitLeft;
    } else {
        return self.anchorLandscapeLeft;
    }
}

- (CGFloat)rightAnchorForInterfaceOrientation {
    if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
        return self.anchorPortraitRight;
    } else {
        return self.anchorLandscapeRight;
    }
}

- (UIViewController *)bestRightAnchorPointViewControllerWithIndex:(NSInteger *)index {
    
    __block NSUInteger bestIndex = 0;
    __block CGFloat bestDistance = CGFLOAT_MAX;
    
    [self.viewControllers enumerateObjectsUsingBlock:^(__strong id obj, NSUInteger idx, BOOL *stop) {
        UIViewController *viewController = obj;
        UIView *view = [self viewForExistingRightViewController:viewController];
        
        CGFloat distance = fabsf(view.center.x - self.rightAnchorForInterfaceOrientation);
        if (distance <= bestDistance) {
            bestDistance = distance;
            bestIndex = idx;
        }
    }];
    
    if (index) {
        *index = bestIndex;
    }
    
    if (bestIndex == NSNotFound) {
        return nil;
    }
    
    return [self.viewControllers objectAtIndex:bestIndex];
}

- (CGFloat)minimumDragOffsetToShowRemoveInformation {
    CGRect frame = self.removeRectangleIndicatorView.frame;
    return CGRectGetWidth(frame) + frame.origin.x + ANAdvancedNavigationControllerDefaultViewControllerWidth/2.0f - 20.0f;
}

- (CGFloat)leftAnchorForInterfaceOrientationAndRightViewController:(UIViewController *)rightViewController {
    CGFloat anchor = self.leftAnchorForInterfaceOrientation;
    NSUInteger index = [self.viewControllers indexOfObject:rightViewController];
    return anchor + index*2;
}

#pragma mark - target actions

- (void)mainPanGestureRecognizedDidRecognizePanGesture:(UIPanGestureRecognizer *)panGestureRecognizer {
    if (panGestureRecognizer.state == UIGestureRecognizerStateBegan) {
        _draggingDistance = 0.0f;
    } else if (panGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        // changed
        CGFloat translation = [panGestureRecognizer translationInView:self.view].x;
        [panGestureRecognizer setTranslation:CGPointZero inView:self.view];
        
        if (self.viewControllers.count == 1) {
            translation /= 2.0f;
        }
        
        _draggingDistance += translation;
        
        [self updateViewControllersWithTranslation:translation];
    } else if (panGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        // check, if we need to pop every viewController except the first one
        if (self.viewControllers.count > 1) {
            UIViewController *firstViewController = [self.viewControllers objectAtIndex:0];
            UIView *view = [self viewForExistingRightViewController:firstViewController];
            if (view.center.x > self.minimumDragOffsetToShowRemoveInformation) {
                [self popViewControllersExceptFirst];
            }
        }
        
        if (self.viewControllers.count > 0) {
            // find that view controller, that is the best for the right anchor position
            NSInteger index = 0;
            UIViewController *viewController = [self bestRightAnchorPointViewControllerWithIndex:&index];
            if (viewController) {
                if (_draggingRightAnchorViewControllerIndex == index && fabsf(_draggingDistance) >= 10.0f) {
                    // we did "swipe", just move the next viewController in that direction in
                    if (_draggingDistance > 0.0f) {
                        index--;
                    } else {
                        index++;
                    }
                    
                    if (index < 0) {
                        index = 0;
                    } else if (index >= self.viewControllers.count) {
                        index = self.viewControllers.count-1;
                    }
                    viewController = [self.viewControllers objectAtIndex:index];
                }
                [self moveRightViewControllerToRightAnchorPoint:viewController animated:YES];
            }
        }
        
        _draggingDistance = 0.0f;
    }
}

#pragma mark - preparing

- (void)prepareViewForPanning {
    UIPanGestureRecognizer *recognizer = [[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(mainPanGestureRecognizedDidRecognizePanGesture:)] autorelease];
    recognizer.maximumNumberOfTouches = 1;
    [self.view addGestureRecognizer:recognizer];
}

#pragma mark - managin rightViewControllerViews

- (void)updateViewControllersShadow:(UIViewController *)rightViewController {
    UIView *view = [self viewForExistingRightViewController:rightViewController];
    CALayer *layer = view.layer;
    layer.shadowPath = [UIBezierPath bezierPathWithRect:view.bounds].CGPath;
}

- (UIView *)viewForRightViewController:(UIViewController *)rightViewController {
    UIView *wrapperView = [[[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, ANAdvancedNavigationControllerDefaultViewControllerWidth, CGRectGetHeight(self.view.bounds))] autorelease];
    wrapperView.backgroundColor = [UIColor blackColor];
    
    rightViewController.view.frame = wrapperView.bounds;
    [wrapperView addSubview:rightViewController.view];
    rightViewController.view.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    wrapperView.autoresizingMask = rightViewController.view.autoresizingMask;
    
    CALayer *layer = wrapperView.layer;
    layer.masksToBounds = NO;
    layer.shadowPath = [UIBezierPath bezierPathWithRect:rightViewController.view.bounds].CGPath;
    layer.shadowColor = [UIColor blackColor].CGColor;
    layer.shadowRadius = 15.0f;
    layer.shadowOpacity = 0.5f;
    layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    
    return wrapperView;
}

- (UIView *)viewForExistingRightViewController:(UIViewController *)rightViewController {
    return rightViewController.view.superview;
}

- (void)removeRightViewControllerView:(UIViewController *)rightViewController animated:(BOOL)animated {
    [rightViewController viewWillDisappear:animated];
    UIView *view = [self viewForExistingRightViewController:rightViewController];
    if (animated) {
        [UIView animateWithDuration:ANAdvancedNavigationControllerDefaultAnimationDuration 
                         animations:^(void) {
                             CGPoint center = view.center;
                             center.x = CGRectGetWidth(self.view.bounds) + ANAdvancedNavigationControllerDefaultLeftViewControllerWidth/2.0f;
                             view.center = center;
                         } 
                         completion:^(BOOL finished) {
                             [view removeFromSuperview];
                             [rightViewController viewDidDisappear:animated];
                         }];
    } else {
        [view removeFromSuperview];
        [rightViewController viewDidDisappear:animated];
    }
    
    [self numberOfRightViewControllersChanged];
}

#pragma mark - updating view hierachies

- (void)popViewControllersExceptFirst {
    NSArray *oldArray = [[self.viewControllers copy] autorelease];
    
    [oldArray enumerateObjectsUsingBlock:^(__strong id obj, NSUInteger idx, BOOL *stop) {
        if (idx > 0) {
            UIViewController *viewController = obj;
            [self removeRightViewController:viewController];
            [self removeRightViewControllerView:viewController animated:NO];
        }
    }];
    
    self.removeRectangleIndicatorView.state = ANRemoveRectangleIndicatorViewStateFlippedToRight;
    [UIView animateWithDuration:ANAdvancedNavigationControllerDefaultAnimationDuration 
                     animations:^(void) {
                         self.removeRectangleIndicatorView.state = ANRemoveRectangleIndicatorViewStateRemovedRight;
                     } 
                     completion:^(BOOL finished) {
                         [self numberOfRightViewControllersChanged];
                     }];
}

- (void)moveRightViewControllerToRightAnchorPoint:(UIViewController *)rightViewController animated:(BOOL)animated {
    if (![self.viewControllers containsObject:rightViewController]) {
        [NSException raise:NSInternalInconsistencyException format:@"rightViewController is not part of the viewController hierarchy"];
    }
    _draggingRightAnchorViewControllerIndex = [self.viewControllers indexOfObject:rightViewController];
    
    void(^animationBlock)(void) = ^(void) {
        if (self.viewControllers.count <= 1) { // only one view controller
            CGFloat anchorPoint = 0.0;
            // move it to the right or to the middle based on interfaceOrientation
            if (UIDeviceOrientationIsPortrait(self.interfaceOrientation)) {
                anchorPoint = self.anchorPortraitRight;
            } else {
                anchorPoint = self.anchorLandscapeMiddle;
            }
            UIView *view = [self viewForExistingRightViewController:rightViewController];
            view.center = CGPointMake(anchorPoint, CGRectGetHeight(self.view.bounds)/2.0f);
        } else {
            // now we have multiple viewControllers
            NSUInteger objectIndex = [self.viewControllers indexOfObject:rightViewController];
            if (objectIndex == 0) {
                // its the first most down viewController
                CGFloat anchorPoint = 0.0;
                // portrait -> move to left, landscape -> move to middle
                if (UIDeviceOrientationIsPortrait(self.interfaceOrientation)) {
                    anchorPoint = self.anchorPortraitRight;
                } else {
                    anchorPoint = self.anchorLandscapeMiddle;
                }
                UIView *view = [self viewForExistingRightViewController:rightViewController];
                view.center = CGPointMake(anchorPoint, CGRectGetHeight(self.view.bounds)/2.0f);
                
                [self.viewControllers enumerateObjectsUsingBlock:^(__strong id obj, NSUInteger idx, BOOL *stop) {
                    if (obj != rightViewController) {
                        UIViewController *viewController = obj;
                        UIView *view = [self viewForExistingRightViewController:viewController];
                        CGFloat newAnchorPoint = anchorPoint + (CGFloat)idx * ANAdvancedNavigationControllerDefaultDraggingDistance;
                        view.center = CGPointMake(newAnchorPoint, CGRectGetHeight(self.view.bounds)/2.0f);
                    }
                }];
            } else {
                // not the first viewController, move it to position right, underlying to left, and overlaying to more right
                [self.viewControllers enumerateObjectsUsingBlock:^(__strong id obj, NSUInteger idx, BOOL *stop) {
                    UIViewController *viewController = obj;
                    UIView *view = [self viewForExistingRightViewController:viewController];
                    
                    CGFloat newAnchorPoint = [self leftAnchorForInterfaceOrientationAndRightViewController:viewController];
                    
                    if (idx == objectIndex) {
                        newAnchorPoint = self.rightAnchorForInterfaceOrientation;
                    } else if (idx > objectIndex) {
                        newAnchorPoint = self.rightAnchorForInterfaceOrientation + (CGFloat)(idx - objectIndex) * ANAdvancedNavigationControllerDefaultDraggingDistance;
                    }
                    view.center = CGPointMake(newAnchorPoint, CGRectGetHeight(self.view.bounds)/2.0f);
                }];
            }
        }
    };
    
    if (animated) {
        [UIView animateWithDuration:ANAdvancedNavigationControllerDefaultAnimationDuration 
                         animations:animationBlock];
    } else {
        animationBlock();
    }
}

- (void)numberOfRightViewControllersChanged {
    if (self.viewControllers.count <= 1) {
        self.removeRectangleIndicatorView.state = ANRemoveRectangleIndicatorViewStateHidden;
    } else {
        self.removeRectangleIndicatorView.state = ANRemoveRectangleIndicatorViewStateVisible;
    }
}

- (void)loadRightViewControllers {
    NSUInteger lastViewControllerIndex = self.viewControllers.count - 1;
    [self.viewControllers enumerateObjectsUsingBlock:^(__strong id obj, NSUInteger idx, BOOL *stop) {
        UIViewController *viewController = obj;
        UIView *view = [self viewForRightViewController:viewController];
        [self.view addSubview:view];
        
        if (idx == lastViewControllerIndex) {
            view.center = CGPointMake(self.rightAnchorForInterfaceOrientation, CGRectGetHeight(self.view.bounds)/2.0f);
        } else {
            view.center = CGPointMake(self.leftAnchorForInterfaceOrientation, CGRectGetHeight(self.view.bounds)/2.0f);
        }
    }];
    
    [self numberOfRightViewControllersChanged];
}

- (void)addRightViewController:(UIViewController *)rightViewController {
    [self.viewControllers addObject:rightViewController];
    [self addChildViewController:rightViewController];
    
    [self numberOfRightViewControllersChanged];
}

- (void)removeRightViewController:(UIViewController *)rightViewController {
    [rightViewController removeFromParentViewController];
    [self.viewControllers removeObject:rightViewController];
    [self numberOfRightViewControllersChanged];
}

- (void)updateViewControllersWithTranslation:(CGFloat)translation {
    NSUInteger count = self.viewControllers.count;
    
    CGFloat minDragOffsetToShowRemoveInformation = self.minimumDragOffsetToShowRemoveInformation;
    __block UIViewController *previousViewController = nil;
    [self.viewControllers enumerateObjectsWithOptions:NSEnumerationReverse 
                                           usingBlock:^(__strong id obj, NSUInteger idx, BOOL *stop) {
                                               UIViewController *currentViewController = obj;
                                               UIView *view = [self viewForExistingRightViewController:currentViewController];
                                               
                                               CGPoint currentCenter = view.center;
                                               CGFloat leftBounds = [self leftAnchorForInterfaceOrientationAndRightViewController:currentViewController];
                                               
                                               if (currentCenter.x + translation < leftBounds) {
                                                   currentCenter.x = leftBounds;
                                               } else {
                                                   if ([self viewForExistingRightViewController:previousViewController].center.x - currentCenter.x >= ANAdvancedNavigationControllerDefaultDraggingDistance || !previousViewController || translation < 0.0f) {
                                                       currentCenter.x += translation;
                                                   }
                                               }
                                               
                                               view.center = currentCenter;
                                               
                                               previousViewController = currentViewController;
                                               
                                               if (count > 1 && idx == 0) {
                                                   // first viewController has moved enough to the right
                                                   if (currentCenter.x > minDragOffsetToShowRemoveInformation) {
                                                       [self.removeRectangleIndicatorView setState:ANRemoveRectangleIndicatorViewStateFlippedToRight animated:YES];
                                                   } else {
                                                       [self.removeRectangleIndicatorView setState:ANRemoveRectangleIndicatorViewStateVisible animated:YES];
                                                   }
                                               }
                                           }];
}

@end
