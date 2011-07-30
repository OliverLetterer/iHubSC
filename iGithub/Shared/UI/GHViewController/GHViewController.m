//
//  GHViewController.m
//  iGithub
//
//  Created by Oliver Letterer on 20.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHViewController.h"
#import "UIColor+GithubUI.h"

@implementation GHViewController

@synthesize navigationTintColor=_navigationTintColor;

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.tintColor = [UIColor defaultNavigationBarTintColor];
}


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

@end
