//
//  GHDateSelectViewController.m
//  iGithub
//
//  Created by Oliver Letterer on 01.08.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHDateSelectViewController.h"
#import "KalDate.h"

@implementation GHDateSelectViewController
@synthesize dateDelegate=_dateDelegate;

#pragma mark - setters and getters

- (void)didSelectDate:(KalDate *)date {
    [super didSelectDate:date];
    [self.dateDelegate dateSelectViewController:self didSelectDate:[date NSDate]];
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel 
                                                                                           target:self 
                                                                                           action:@selector(cancelButtonClicked:)];
}

#pragma mark - target actions

- (void)cancelButtonClicked:(UIBarButtonItem *)sender {
    [self.dateDelegate dateSelectViewControllerDidCancel:self];
}

@end
