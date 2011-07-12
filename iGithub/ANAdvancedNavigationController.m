//
//  ANAdvancedNavigationController.m
//  ANAdvancedNavigationController
//
//  Created by Oliver Letterer on 28.06.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ANAdvancedNavigationController.h"
#import "ANAdvancedNavigationController+private.h"
#import "ANAdvancedNavigationController+LeftViewController.h"
#import "ANAdvancedNavigationController+MovingRightViewControllers.h"
#import <QuartzCore/QuartzCore.h>

const CGFloat ANAdvancedNavigationControllerDefaultLeftViewControllerWidth  = 291.0f;
const CGFloat ANAdvancedNavigationControllerDefaultViewControllerWidth      = 475.0f;
const CGFloat ANAdvancedNavigationControllerDefaultLeftPanningOffset        = 75.0f;

const CGFloat ANAdvancedNavigationControllerDefaultAnimationDuration        = 0.35f;
const CGFloat ANAdvancedNavigationControllerDefaultDraggingDistance         = 473.0f;// = ANAdvancedNavigationControllerDefaultViewControllerWidth - 2.0f

@implementation ANAdvancedNavigationController

@synthesize backgroundView=_backgroundView;
@synthesize leftViewController=_leftViewController, viewControllers=_viewControllers, removeRectangleIndicatorView=_removeRectangleIndicatorView;

#pragma mark - setters and getters

- (void)setLeftViewController:(UIViewController *)leftViewController {
    if (_leftViewController != leftViewController) {
        [self replaceLeftViewControllerWithViewController:leftViewController];
        _leftViewController = leftViewController;
    }
}

- (void)setBackgroundView:(UIView *)backgroundView {
    if (backgroundView != _backgroundView) {
        [_backgroundView removeFromSuperview];
        _backgroundView = backgroundView;
        [self updateBackgroundView];
    }
}

#pragma mark - initialization

- (id)init {
    if ((self = [super init])) {
        if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
            [NSException raise:NSInternalInconsistencyException format:@"ANAdvancedNavigationController is only supposed to work on iPad"];
        }
        self.viewControllers = [NSMutableArray array];
    }
    return self;
}

- (id)initWithLeftViewController:(UIViewController *)leftViewController {
    if ((self = [self init])) {
        self.leftViewController = leftViewController;
    }
    return self;
}

- (id)initWithLeftViewController:(UIViewController *)leftViewController rightViewControllers:(NSArray *)rightViewControllers {
    if (self = [self initWithLeftViewController:leftViewController]) {
        [rightViewControllers enumerateObjectsUsingBlock:^(__strong id obj, NSUInteger idx, BOOL *stop) {
            [self addRightViewController:obj];
        }];
    }
    return self;
}

#pragma mark - instance methods

- (void)pushRootViewController:(UIViewController *)rootViewController {
    NSArray *oldArray = [[self.viewControllers copy] autorelease];
    
    [oldArray enumerateObjectsUsingBlock:^(__strong id obj, NSUInteger idx, BOOL *stop) {
        [self _removeRightViewController:obj animated:YES];
    }];
    
    [self addRightViewController:rootViewController];
    
    // now display the new rootViewController, if the view is loaded
    UIView *newView = self.isViewLoaded ? [self viewForRightViewController:rootViewController] : nil;
    
    if (newView) {
        [self.view addSubview:newView];
        newView.center = CGPointMake(CGRectGetWidth(self.view.bounds) + ANAdvancedNavigationControllerDefaultViewControllerWidth/2.0f, CGRectGetHeight(self.view.bounds)/2.0f);
        [self moveRightViewControllerToRightAnchorPoint:rootViewController animated:YES];
    }
}

- (void)pushViewController:(UIViewController *)viewController afterViewController:(UIViewController *)afterViewController {
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
        [self _removeRightViewController:obj animated:YES];
    }];
    
    // insert viewController in data structure
    [self addRightViewController:viewController];
    
    UIView *newView = self.isViewLoaded ? [self viewForRightViewController:viewController] : nil;
    
    if (newView) {
        [self.view addSubview:newView];
        newView.center = CGPointMake(CGRectGetWidth(self.view.bounds)+ANAdvancedNavigationControllerDefaultViewControllerWidth/2.0f, CGRectGetHeight(self.view.bounds)/2.0f);
        // now insert the new view into our view hirarchy
        [self moveRightViewControllerToRightAnchorPoint:viewController animated:YES];
    }
}

- (void)popViewController:(UIViewController *)viewController {
    if (![self.viewControllers containsObject:viewController]) {
        [NSException raise:NSInternalInconsistencyException format:@"viewController (%@) is not part of the viewController Hierarchy", viewController];
    }
    
    NSInteger index = [self.viewControllers indexOfObject:viewController]-1;
    
    if (index >= 0) {
        viewController = [self.viewControllers objectAtIndex:index];
        [self popViewControllersToViewController:viewController];
    }
}

- (void)popViewControllersToViewController:(UIViewController *)viewController {
    if (![self.viewControllers containsObject:viewController]) {
        [NSException raise:NSInternalInconsistencyException format:@"viewController (%@) is not part of the viewController Hierarchy", viewController];
    }
    
    NSInteger index = [self.viewControllers indexOfObject:viewController]+1;
    [self.viewControllers enumerateObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(index, self.viewControllers.count-index)] 
                                            options:NSEnumerationConcurrent 
                                         usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                                             [self _removeRightViewController:obj animated:YES];
                                         }];
    
    [self moveRightViewControllerToRightAnchorPoint:viewController animated:YES];
}

#pragma mark - memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGFloat removeHeight = 75.0f;
    self.removeRectangleIndicatorView = [[[ANRemoveRectangleIndicatorView alloc] initWithFrame:CGRectMake(ANAdvancedNavigationControllerDefaultLeftViewControllerWidth + 5.0f, CGRectGetHeight(self.view.bounds)/2.0f-removeHeight, 175.0f, removeHeight*2.0f)] autorelease];
    self.removeRectangleIndicatorView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    [self.view insertSubview:self.removeRectangleIndicatorView atIndex:0];
    
    self.view.backgroundColor = [UIColor darkGrayColor];
    [self updateBackgroundView];
    [self loadAndPrepareLeftViewController:self.leftViewController];
    [self prepareViewForPanning];
    [self loadRightViewControllers];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    [_removeRectangleIndicatorView release], _removeRectangleIndicatorView = nil;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

#pragma mark - memory management

- (void)dealloc {
    
    [_leftViewController release];
    [_backgroundView release];
    [_viewControllers release];
    [_removeRectangleIndicatorView release];
    
    [super dealloc];
}

#pragma mark - rotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    for (UIViewController *viewController in self.childViewControllers) {
        if (![viewController shouldAutorotateToInterfaceOrientation:interfaceOrientation]) {
            return NO;
        }
    }
	return YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    [self.viewControllers enumerateObjectsUsingBlock:^(__strong id obj, NSUInteger idx, BOOL *stop) {
        [self updateViewControllersShadow:obj];
    }];
    if (self.viewControllers.count > _draggingRightAnchorViewControllerIndex) {
        [self moveRightViewControllerToRightAnchorPoint:[self.viewControllers objectAtIndex:_draggingRightAnchorViewControllerIndex] animated:NO];
    }
}

#pragma mark - private implementation

- (void)updateBackgroundView {
    if (self.isViewLoaded) {
        _backgroundView.frame = self.view.bounds;
        _backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.view insertSubview:_backgroundView atIndex:0];
    }
}

@end






@implementation UIViewController (ANAdvancedNavigationController)

- (ANAdvancedNavigationController *)advancedNavigationController {
    UIViewController *viewController = self.parentViewController;
    while (viewController != nil) {
        if ([viewController isKindOfClass:[ANAdvancedNavigationController class] ]) {
            return (ANAdvancedNavigationController *)viewController;
        } else {
            viewController = viewController.parentViewController;
        }
    }
    return nil;
}

@end
