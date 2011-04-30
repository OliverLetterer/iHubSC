//
//  GHMilestone.m
//  iGithub
//
//  Created by Oliver Letterer on 30.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHMilestone.h"
#import "GithubAPI.h"

@implementation GHMilestone

@synthesize closedIssues=_closedIssues, createdAt=_createdAt, creator=_creator, milestoneDescription=_milestoneDescription, duoOn=_duoOn, number=_number, openIssues=_openIssues, state=_state, title=_title, URL=_URL;

#pragma mark - Initialization

- (id)initWithRawDictionary:(NSDictionary *)rawDictionay {
    if ((self = [super init])) {
        // Initialization code
        self.closedIssues = [rawDictionay objectForKeyOrNilOnNullObject:@"closed_issues"];
        self.createdAt = [rawDictionay objectForKeyOrNilOnNullObject:@"created_at"];
        self.milestoneDescription = [rawDictionay objectForKeyOrNilOnNullObject:@"description"];
        self.duoOn = [rawDictionay objectForKeyOrNilOnNullObject:@"due_on"];
        self.number = [rawDictionay objectForKeyOrNilOnNullObject:@"number"];
        self.openIssues = [rawDictionay objectForKeyOrNilOnNullObject:@"open_issues"];
        self.state = [rawDictionay objectForKeyOrNilOnNullObject:@"state"];
        self.title = [rawDictionay objectForKeyOrNilOnNullObject:@"title"];
        self.URL = [rawDictionay objectForKeyOrNilOnNullObject:@"url"];
        self.creator = [[[GHUser alloc] initWithRawDictionary:[rawDictionay objectForKeyOrNilOnNullObject:@"creator"] ] autorelease];
    }
    return self;
}

#pragma mark - Memory management

- (void)dealloc {
    [_closedIssues release];
    [_createdAt release];
    [_creator release];
    [_milestoneDescription release];
    [_duoOn release];
    [_number release];
    [_openIssues release];
    [_state release];
    [_title release];
    [_URL release];
    
    [super dealloc];
}

@end
