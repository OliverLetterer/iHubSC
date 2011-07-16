//
//  GHOwnerNewsFeedViewController+Private.m
//  iGithub
//
//  Created by Oliver Letterer on 23.06.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHOwnerNewsFeedViewController+Private.h"
#import "UIColor+GithubUI.h"

@implementation GHOwnerNewsFeedViewController (Private)

- (BOOL)isStateSegmentControlLoaded {
    return self.stateSegmentControl != nil;
}

- (void)loadStateSegmentControl {
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    animation.calculationMode = kCAAnimationCubic;
    animation.values = [NSArray arrayWithObjects:[NSValue valueWithCATransform3D:CATransform3DMakeTranslation(0.0f, -50.0f, 0.0f)],
                        [NSValue valueWithCATransform3D:CATransform3DMakeTranslation(0.0f, 0.0f, 0.0f)],
                        [NSValue valueWithCATransform3D:CATransform3DMakeTranslation(0.0f, -25.0f, 0.0f)],
                        [NSValue valueWithCATransform3D:CATransform3DMakeTranslation(0.0f, 0.0f, 0.0f)],
                        [NSValue valueWithCATransform3D:CATransform3DMakeTranslation(0.0f, -7.25f, 0.0f)],
                        [NSValue valueWithCATransform3D:CATransform3DMakeTranslation(0.0f, 0.0f, 0.0f)],
                        nil];
    animation.duration = 0.5f;
    
    UISegmentedControl *segmentControl = [[[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"", nil]] autorelease];
    segmentControl.segmentedControlStyle = UISegmentedControlStyleBar;
    segmentControl.tintColor = [UIColor defaultNavigationBarTintColor];
    segmentControl.frame = CGRectMake(0.0f, 0.0f, 286.0f, 32.0f);
    segmentControl.userInteractionEnabled = NO;
    
    [self.navigationItem.titleView addSubview:segmentControl];
    [self.segmentControl bringSubviewToFront:segmentControl];
    [segmentControl.layer addAnimation:animation forKey:@"transform"];
    
    self.stateSegmentControl = segmentControl;
}

- (void)unloadStateSegmentControlIfPossible {
    NSDate *now = [NSDate date];
    if (fabsf([now timeIntervalSinceDate:self.lastStateUpdateDate]) >= 2.0f) {
        CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
        animation.calculationMode = kCAAnimationLinear;
        animation.values = [NSArray arrayWithObjects:[NSValue valueWithCATransform3D:CATransform3DIdentity],
                            [NSValue valueWithCATransform3D:CATransform3DMakeTranslation(0.0f, -50.0f, 0.0f)],
                            [NSValue valueWithCATransform3D:CATransform3DMakeTranslation(0.0f, -50.0f, 0.0f)],
                            nil];
        animation.duration = 0.6f;
        [self.stateSegmentControl.layer addAnimation:animation forKey:@"transform"];
        [self.stateSegmentControl performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:0.3f];
        self.stateSegmentControl = nil;
    }
}

- (void)detachNewStateString:(NSString *)stateString removeAfterDisplayed:(BOOL)removeFlag {
    if (!self.isStateSegmentControlLoaded) {
        [self loadStateSegmentControl];
    }
    [self.stateSegmentControl setTitle:stateString forSegmentAtIndex:0];
    self.lastStateUpdateDate = [NSDate date];
    if (removeFlag) {
        [self performSelector:@selector(unloadStateSegmentControlIfPossible) withObject:nil afterDelay:2.1f];
    }
}

@end
