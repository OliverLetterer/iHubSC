//
//  ANAdvancedNavigationController+RightViewControllers.m
//  iGithub
//
//  Created by Oliver Letterer on 14.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "ANAdvancedNavigationController+RightViewControllers.h"
#import "ANAdvancedNavigationController+private.h"
#import "ANAdvancedNavigationController+RightViewControllers+Anchors.h"
#import <QuartzCore/QuartzCore.h>

@interface ANAdvancedNavigationController (ANAdvancedNavigationController_RightViewControllers_Private)

// inserting new viewControllers
- (void)__pushRootViewController:(UIViewController *)rootViewController animated:(BOOL)animated;
- (void)__pushViewController:(UIViewController *)viewController afterViewController:(UIViewController *)afterViewController animated:(BOOL)animated;

// removing old viewControllers
- (void)__removeRightViewController:(UIViewController *)rightViewController animated:(BOOL)animated;

// concistency stuff
- (void)__numberOfRightViewControllersDidChanged;

// managing rightViewControllers views
- (UIView *)__loadViewForNewRightViewController:(UIViewController *)rightViewController;
- (UIView *)__viewForRightViewController:(UIViewController *)rightViewController;

// panning
- (UIViewController *)__bestRightAnchorPointViewControllerWithIndex:(NSInteger *)index;
- (void)__updateViewControllersWithTranslation:(CGFloat)translation;
- (void)__mainPanGestureRecognizedDidRecognizePanGesture:(UIPanGestureRecognizer *)panGestureRecognizer;

- (void)__popViewControllersAfterDraggingFarToTheRight;

@end

@implementation ANAdvancedNavigationController (ANAdvancedNavigationController_RightViewControllers_Private)

#pragma mark - inserting new viewControllers

- (void)__pushRootViewController:(UIViewController *)rootViewController animated:(BOOL)animated {
    NSArray *oldViewControllers = [[self.viewControllers copy] autorelease];
    
    [oldViewControllers enumerateObjectsUsingBlock:^(__strong id obj, NSUInteger idx, BOOL *stop) {
        [self __removeRightViewController:obj animated:animated];
    }];
    
    [self.viewControllers addObject:rootViewController];
    [self addChildViewController:rootViewController];
    [self __numberOfRightViewControllersDidChanged];
    
    // now display the new rootViewController, if the view is loaded
    UIView *newView = [self __loadViewForNewRightViewController:rootViewController];
    
    [rootViewController viewWillAppear:animated];
    if (newView) {
        newView.center = CGPointMake(CGRectGetWidth(self.view.bounds) + ANAdvancedNavigationControllerDefaultViewControllerWidth/2.0f, CGRectGetHeight(self.view.bounds)/2.0f);
        [self.view addSubview:newView];
        CGPoint nextCenterPoint = [self __centerPointForRightViewController:rootViewController withIndexOfCurrentViewControllerAtRightAnchor:0];
        if (animated) {
            [UIView animateWithDuration:ANAdvancedNavigationControllerDefaultAnimationDuration 
                             animations:^(void) {
                                 newView.center = nextCenterPoint;
                             } 
                             completion:^(BOOL finished) {
                                 [rootViewController viewDidAppear:animated];
                                 [rootViewController didMoveToParentViewController:self];
                             }];
        } else {
            newView.center = nextCenterPoint;
            [rootViewController viewDidAppear:animated];
            [rootViewController didMoveToParentViewController:self];
        }
    }
}

- (void)__pushViewController:(UIViewController *)viewController afterViewController:(UIViewController *)afterViewController animated:(BOOL)animated {
    if ([self.viewControllers containsObject:viewController]) {
        [NSException raise:NSInternalInconsistencyException format:@"viewController (%@) is already part of the viewController Hierarchy", viewController];
    }
    if (![self.viewControllers containsObject:afterViewController]) {
        [NSException raise:NSInternalInconsistencyException format:@"afterViewController (%@) is not part of the viewController Hierarchy", afterViewController];
    }
    
    NSUInteger afterIndex = [self.viewControllers indexOfObject:afterViewController]+1;
    NSIndexSet *deleteIndexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(afterIndex, self.viewControllers.count - afterIndex)];
    
    NSArray *oldViewControllers = [self.viewControllers objectsAtIndexes:deleteIndexSet];
    
    // remove all viewControllers, that come after afterViewController
    [oldViewControllers enumerateObjectsUsingBlock:^(__strong id obj, NSUInteger idx, BOOL *stop) {
        [self __removeRightViewController:obj animated:animated];
    }];
    
    // insert viewController in data structure
    [self.viewControllers addObject:viewController];
    [self addChildViewController:viewController];
    [self __numberOfRightViewControllersDidChanged];
    
    UIView *newView = [self __loadViewForNewRightViewController:viewController];
    
    [viewController viewWillAppear:animated];
    if (newView) {
        [self.view addSubview:newView];
        newView.center = CGPointMake(CGRectGetWidth(self.view.bounds)+ANAdvancedNavigationControllerDefaultViewControllerWidth/2.0f, CGRectGetHeight(self.view.bounds)/2.0f);
        // now insert the new view into our view hirarchy
        if (animated) {
            [UIView animateWithDuration:ANAdvancedNavigationControllerDefaultAnimationDuration 
                             animations:^(void) {
                                 [self.viewControllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                                     UIView *view = [self __viewForRightViewController:obj];
                                     view.center = [self __centerPointForRightViewController:obj 
                                               withIndexOfCurrentViewControllerAtRightAnchor:self.viewControllers.count-1];
                                 }];
                             } 
                             completion:^(BOOL finished) {
                                 [viewController viewDidAppear:animated];
                                 [viewController didMoveToParentViewController:self];
                             }];
        } else {
            [self.viewControllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                UIView *view = [self __viewForRightViewController:obj];
                view.center = [self __centerPointForRightViewController:obj 
                          withIndexOfCurrentViewControllerAtRightAnchor:self.viewControllers.count-1];
            }];
            [viewController viewDidAppear:animated];
            [viewController didMoveToParentViewController:self];
        }
    }
}

#pragma mark - removing old viewControllers

- (void)__removeRightViewController:(UIViewController *)rightViewController animated:(BOOL)animated {
    if (![self.viewControllers containsObject:rightViewController]) {
        [NSException raise:NSInternalInconsistencyException format:@"rightViewController (%@) is not part of the viewController Hierarchy", rightViewController];
    }
    
    [rightViewController willMoveToParentViewController:nil];
    
    [self.viewControllers removeObject:rightViewController];
    [self __numberOfRightViewControllersDidChanged];
    
    [rightViewController viewWillDisappear:animated];
    UIView *view = [self __viewForRightViewController:rightViewController];
    if (animated) {
        [UIView animateWithDuration:ANAdvancedNavigationControllerDefaultAnimationDuration 
                         animations:^(void) {
                             CGPoint center = view.center;
                             center.x = CGRectGetWidth(self.view.bounds) + ANAdvancedNavigationControllerDefaultLeftViewControllerWidth;
                             view.center = center;
                         } 
                         completion:^(BOOL finished) {
                             [view removeFromSuperview];
                             [rightViewController viewDidDisappear:animated];
                             [rightViewController removeFromParentViewController];
                         }];
    } else {
        [view removeFromSuperview];
        [rightViewController viewDidDisappear:animated];
        [rightViewController removeFromParentViewController];
    }
}

- (void)__popViewControllersAfterDraggingFarToTheRight {
    NSArray *oldArray = [[self.viewControllers copy] autorelease];
    
    [oldArray enumerateObjectsUsingBlock:^(__strong id obj, NSUInteger idx, BOOL *stop) {
        if (idx > 0) {
            [self __removeRightViewController:obj animated:NO];
        }
    }];
    
    self.removeRectangleIndicatorView.state = ANRemoveRectangleIndicatorViewStateFlippedToRight;
    [UIView animateWithDuration:ANAdvancedNavigationControllerDefaultAnimationDuration 
                     animations:^(void) {
                         self.removeRectangleIndicatorView.state = ANRemoveRectangleIndicatorViewStateRemovedRight;
                     } 
                     completion:^(BOOL finished) {
                         [self __numberOfRightViewControllersDidChanged];
                     }];
}

#pragma mark - concistency stuff

- (void)__numberOfRightViewControllersDidChanged {
    if (self.viewControllers.count <= 1) {
        [self.removeRectangleIndicatorView setState:ANRemoveRectangleIndicatorViewStateHidden animated:YES];
    } else {
        [self.removeRectangleIndicatorView setState:ANRemoveRectangleIndicatorViewStateVisible animated:YES];
    }
}

#pragma mark - rightViewControllers views

- (UIView *)__loadViewForNewRightViewController:(UIViewController *)rightViewController {
    if (!self.isViewLoaded) {
        return nil;
    }
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

- (UIView *)__viewForRightViewController:(UIViewController *)rightViewController {
    return rightViewController.view.superview;
}

#pragma mark - Panning

- (UIViewController *)__bestRightAnchorPointViewControllerWithIndex:(NSInteger *)index {
    
    __block NSUInteger bestIndex = 0;
    __block CGFloat bestDistance = CGFLOAT_MAX;
    
    [self.viewControllers enumerateObjectsUsingBlock:^(__strong id obj, NSUInteger idx, BOOL *stop) {
        UIViewController *viewController = obj;
        UIView *view = [self __viewForRightViewController:viewController];
        
        CGFloat distance = fabsf(view.center.x - self.__rightAnchorForInterfaceOrientation);
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

- (void)__updateViewControllersWithTranslation:(CGFloat)translation {
    NSUInteger count = self.viewControllers.count;
    
    CGFloat minDragOffsetToShowRemoveInformation = self.__minimumDragOffsetToShowRemoveInformation;
    __block UIViewController *previousViewController = nil;
    [self.viewControllers enumerateObjectsWithOptions:NSEnumerationReverse 
                                           usingBlock:^(__strong id obj, NSUInteger idx, BOOL *stop) {
                                               UIViewController *currentViewController = obj;
                                               UIView *view = [self __viewForRightViewController:currentViewController];
                                               
                                               CGPoint currentCenter = view.center;
                                               CGFloat leftBounds = [self __leftAnchorForInterfaceOrientationAndRightViewController:currentViewController];
                                               
                                               if (currentCenter.x + translation < leftBounds) {
                                                   currentCenter.x = leftBounds;
                                               } else {
                                                   if ([self __viewForRightViewController:previousViewController].center.x - currentCenter.x >= ANAdvancedNavigationControllerDefaultDraggingDistance || !previousViewController || translation < 0.0f) {
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

- (void)__mainPanGestureRecognizedDidRecognizePanGesture:(UIPanGestureRecognizer *)panGestureRecognizer {
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
        
        [self __updateViewControllersWithTranslation:translation];
    } else if (panGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        // check, if we need to pop every viewController except the first one
        if (self.viewControllers.count > 1) {
            UIViewController *firstViewController = [self.viewControllers objectAtIndex:0];
            UIView *view = [self __viewForRightViewController:firstViewController];
            if (view.center.x > self.__minimumDragOffsetToShowRemoveInformation) {
                [self __popViewControllersAfterDraggingFarToTheRight];
            }
        }
        
        if (self.viewControllers.count > 0) {
            // find that view controller, that is the best for the right anchor position
            NSInteger index = 0;
            UIViewController *viewController = [self __bestRightAnchorPointViewControllerWithIndex:&index];
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
                [self _moveRightViewControllerToRightAnchorPoint:viewController animated:YES];
            }
        }
        
        _draggingDistance = 0.0f;
    }
}

@end






@implementation ANAdvancedNavigationController (ANAdvancedNavigationController_RightViewControllers)

- (void)_pushViewController:(UIViewController *)viewController 
        afterViewController:(UIViewController *)afterViewController animated:(BOOL)animated {
    // first lets do some concistency checks
    if ([self.viewControllers containsObject:viewController] || _leftViewController == viewController) {
        // viewController cant be part of the current viewController hierarchy
        [NSException raise:NSInternalInconsistencyException format:@"viewController (%@) is already part of the viewController Hierarchy", viewController];
    }
    if (![self.viewControllers containsObject:afterViewController] && afterViewController != nil) {
        [NSException raise:NSInternalInconsistencyException format:@"afterViewController (%@) is not part of the viewController Hierarchy", afterViewController];
    }
    
    if (afterViewController == _leftViewController) {
        afterViewController = nil;
    }
    
    if (afterViewController == nil) {
        // we need to push a new rootViewController
        [self __pushRootViewController:viewController animated:animated];
    } else {
        [self __pushViewController:viewController afterViewController:afterViewController animated:animated];
    }
    
    _draggingRightAnchorViewControllerIndex = [self.viewControllers indexOfObject:viewController];
}

- (void)_popViewControllersToViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (![self.viewControllers containsObject:viewController]) {
        [NSException raise:NSInternalInconsistencyException format:@"viewController (%@) is not part of the viewController Hierarchy", viewController];
    }
    
    NSArray *oldArray = [[self.viewControllers copy] autorelease];
    
    NSInteger index = [self.viewControllers indexOfObject:viewController]+1;
    [oldArray enumerateObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(index, self.viewControllers.count-index)] 
                                options:NSEnumerationConcurrent 
                             usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                                 [self __removeRightViewController:obj animated:YES];
                             }];
    
    [self _moveRightViewControllerToRightAnchorPoint:viewController animated:YES];
}

- (void)_moveRightViewControllerToRightAnchorPoint:(UIViewController *)rightViewController animated:(BOOL)animated {
    NSUInteger rightViewControllerIndex = [self.viewControllers indexOfObject:rightViewController];
    _draggingRightAnchorViewControllerIndex = rightViewControllerIndex;
    
    if (animated) {
        [UIView animateWithDuration:ANAdvancedNavigationControllerDefaultAnimationDuration 
                         animations:^(void) {
                             [self.viewControllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                                 UIView *view = [self __viewForRightViewController:obj];
                                 view.center = [self __centerPointForRightViewController:obj withIndexOfCurrentViewControllerAtRightAnchor:rightViewControllerIndex];
                             }];
                         }];
    } else {
        [self.viewControllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            UIView *view = [self __viewForRightViewController:obj];
            view.center = [self __centerPointForRightViewController:obj withIndexOfCurrentViewControllerAtRightAnchor:rightViewControllerIndex];
        }];
    }
}

- (void)_updateViewControllerShadows {
    [self.viewControllers enumerateObjectsUsingBlock:^(__strong id obj, NSUInteger idx, BOOL *stop) {
        UIView *view = [self __viewForRightViewController:obj];
        CALayer *layer = view.layer;
        layer.shadowPath = [UIBezierPath bezierPathWithRect:view.bounds].CGPath;
    }];
}

- (void)_prepareViewForPanning {
    UIPanGestureRecognizer *recognizer = [[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(__mainPanGestureRecognizedDidRecognizePanGesture:)] autorelease];
    recognizer.maximumNumberOfTouches = 1;
    [self.view addGestureRecognizer:recognizer];
}

- (void)_willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    for (UIViewController *viewController in self.childViewControllers) {
        [viewController willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    }
    [self _updateViewControllerShadows];
    
    if (self.viewControllers.count > _draggingRightAnchorViewControllerIndex) {
        [self _moveRightViewControllerToRightAnchorPoint:[self.viewControllers objectAtIndex:_draggingRightAnchorViewControllerIndex] animated:NO];
    }
}

- (void)_insertRightViewController:(UIViewController *)rightViewController {
    [self.viewControllers addObject:rightViewController];
    [self addChildViewController:rightViewController];
    [self __numberOfRightViewControllersDidChanged];
}

- (void)_insertRightViewControllerViews {
    NSUInteger lastIndex = self.viewControllers.count-1;
    [self.viewControllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIViewController *viewController = obj;
        UIView *view = [self __loadViewForNewRightViewController:viewController];
        [viewController viewWillAppear:NO];
        [self.view addSubview:view];
        view.center = [self __centerPointForRightViewController:viewController withIndexOfCurrentViewControllerAtRightAnchor:lastIndex];
        [viewController viewDidAppear:NO];
    }];
}

@end
