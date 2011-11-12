//
//  GHViewController.m
//  iGithub
//
//  Created by Oliver Letterer on 20.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHViewController.h"
#import "UIColor+GithubUI.h"
#import <QuartzCore/QuartzCore.h>

@implementation GHViewController
@synthesize navigationTintColor=_navigationTintColor;
@synthesize presentedInPopoverController=_presentedInPopoverController;

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.title forKey:@"title"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        self.title = [decoder decodeObjectForKey:@"title"];
    }
    return self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return YES;
    } else {
        return toInterfaceOrientation == UIInterfaceOrientationPortrait;
    }
}

#pragma mark - setters and getters

- (UIView *)tableFooterShadowView {
    NSDictionary *newActions = [NSDictionary dictionaryWithObjectsAndKeys:[NSNull null], @"onOrderIn",
                                [NSNull null], @"onOrderOut",
                                [NSNull null], @"sublayers",
                                [NSNull null], @"contents",
                                [NSNull null], @"bounds",
                                nil];
    
    CAGradientLayer *gradientLayer = nil;
    UIView *view = nil;
    
    view = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 22.0f)];
    view.backgroundColor = [UIColor clearColor];
    gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = CGRectMake(0.0f, 0.0f, 480.0f, 22.0f);
    gradientLayer.colors = [NSArray arrayWithObjects:
                            (__bridge id)[UIColor colorWithWhite:0.0f alpha:0.3f].CGColor,
                            (__bridge id)[UIColor colorWithWhite:0.0f alpha:0.0f].CGColor,
                            nil];
    gradientLayer.actions = newActions;
    [view.layer addSublayer:gradientLayer];
    
    return view;
}

- (UIView *)tableHeaderShadowView {
    NSDictionary *newActions = [NSDictionary dictionaryWithObjectsAndKeys:[NSNull null], @"onOrderIn",
                                [NSNull null], @"onOrderOut",
                                [NSNull null], @"sublayers",
                                [NSNull null], @"contents",
                                [NSNull null], @"bounds",
                                nil];
    
    CAGradientLayer *gradientLayer = nil;
    UIView *view = nil;
    
    view = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 22.0f)];
    view.backgroundColor = [UIColor clearColor];
    gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = CGRectMake(0.0f, 0.0f, 480.0f, 22.0f);
    gradientLayer.colors = [NSArray arrayWithObjects:
                            (__bridge id)[UIColor colorWithWhite:0.0f alpha:0.0f].CGColor,
                            (__bridge id)[UIColor colorWithWhite:0.0f alpha:0.3f].CGColor,
                            nil];
    gradientLayer.actions = newActions;
    [view.layer addSublayer:gradientLayer];
    return view;
}

@end
