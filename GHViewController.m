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

- (void)dealloc {
    [_navigationTintColor release];
    
    [super dealloc];
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder];
    [coder encodeObject:self.title forKey:@"title"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        self.title = [decoder decodeObjectForKey:@"title"];
    }
    return self;
}

@end
