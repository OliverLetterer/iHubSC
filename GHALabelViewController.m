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


#pragma mark - Height Caching

- (void)cacheHeightForOpenIssuesArray {
    
}

- (void)cacheHeightForClosedIssuesArray {
    
}

#pragma mark - Keyed Archiving

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:_repositoryString forKey:@"repositoryString"];
    [encoder encodeObject:_label forKey:@"label"];
    [encoder encodeObject:_openIssues forKey:@"openIssues"];
    [encoder encodeObject:_closedIssues forKey:@"closedIssues"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super initWithCoder:decoder])) {
        _repositoryString = [decoder decodeObjectForKey:@"repositoryString"];
        _label = [decoder decodeObjectForKey:@"label"];
        _openIssues = [decoder decodeObjectForKey:@"openIssues"];
        _closedIssues = [decoder decodeObjectForKey:@"closedIssues"];
    }
    return self;
}

@end
