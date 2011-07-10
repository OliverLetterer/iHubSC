//
//  GHALabelViewController.m
//  iGithub
//
//  Created by Oliver Letterer on 09.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHALabelViewController.h"


@implementation GHALabelViewController

@synthesize repositoryString=_repositoryString;
@synthesize label=_label;
@synthesize openIssues=_openIssues, closedIssues=_closedIssues;

#pragma mark - Initialization

- (id)initWithRepository:(NSString *)repository label:(GHAPILabelV3 *)label {
    if ((self = [super initWithStyle:UITableViewStylePlain])) {
        // Custom initialization
        self.repositoryString = repository;
        self.label = label;
        
        self.title = label.name;
    }
    return self;
}

#pragma mark - Memory management

- (void)dealloc {
    [_repositoryString release];
    [_label release];
    [_openIssues release];
    [_closedIssues release];
    
    [super dealloc];
}

#pragma mark - Height Caching

- (void)cacheHeightForOpenIssuesArray {
    
}

- (void)cacheHeightForClosedIssuesArray {
    
}


@end
