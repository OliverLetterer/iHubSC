//
//  ANAdvancedNavigationController+private.h
//  ANAdvancedNavigationController
//
//  Created by Oliver Letterer on 28.06.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ANAdvancedNavigationController.h"
#import <UIKit/UIKit.h>
#import "ANRemoveRectangleIndicatorView.h"

extern const CGFloat ANAdvancedNavigationControllerDefaultAnimationDuration;
extern const CGFloat ANAdvancedNavigationControllerDefaultDraggingDistance;

@interface ANAdvancedNavigationController () {
    UIViewController *_leftViewController;
    UIView *_backgroundView;
    
    NSMutableArray *_viewControllers;
    
    CGFloat _draggingDistance;
    NSInteger _draggingRightAnchorViewControllerIndex;
    
    ANRemoveRectangleIndicatorView *_removeRectangleIndicatorView;
}

- (void)updateBackgroundView;

@property (nonatomic, retain) UIViewController *leftViewController;
@property (nonatomic, retain) NSMutableArray *viewControllers;

@property (nonatomic, retain) ANRemoveRectangleIndicatorView *removeRectangleIndicatorView;

@end
