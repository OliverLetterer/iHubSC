//
//  GHRawIssue.m
//  iGithub
//
//  Created by Oliver Letterer on 10.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHRawIssue.h"
#import "GithubAPI.h"

@implementation GHRawIssue

@synthesize gravatarID=_gravatarID, position=_position, number=_number, votes=_votes, creationDate=_creationDate, comments=_comments, body=_body, title=_title, updatedAd=_updatedAd, closedAd=_closedAd, user=_user, labelsJSON=_labelsJSON, state=_state;

#pragma mark - Initialization

- (id)initWithRawDictionary:(NSDictionary *)rawDictionary {
    if ((self = [super init])) {
        // Initialization code
        self.gravatarID = [rawDictionary objectForKeyOrNilOnNullObject:@"gravatar_id"];
        self.position = [rawDictionary objectForKeyOrNilOnNullObject:@"position"];
        self.number = [rawDictionary objectForKeyOrNilOnNullObject:@"number"];
        self.votes = [rawDictionary objectForKeyOrNilOnNullObject:@"votes"];
        self.creationDate = [rawDictionary objectForKeyOrNilOnNullObject:@"created_at"];
        self.comments = [rawDictionary objectForKeyOrNilOnNullObject:@"comments"];
        self.body = [rawDictionary objectForKeyOrNilOnNullObject:@"body"];
        self.title = [rawDictionary objectForKeyOrNilOnNullObject:@"title"];
        self.updatedAd = [rawDictionary objectForKeyOrNilOnNullObject:@"updated_at"];
        self.closedAd = [rawDictionary objectForKeyOrNilOnNullObject:@"closed_at"];
        self.user = [rawDictionary objectForKeyOrNilOnNullObject:@"user"];
        self.labelsJSON = [(NSArray *)[rawDictionary objectForKeyOrNilOnNullObject:@"labels"] JSONString];
        self.state = [rawDictionary objectForKeyOrNilOnNullObject:@"state"];
    }
    return self;
}

#pragma mark - Memory management

- (void)dealloc {
    [_gravatarID release];
    [_position release];
    [_number release];
    [_votes release];
    [_creationDate release];
    [_comments release];
    [_body release];
    [_title release];
    [_updatedAd release];
    [_closedAd release];
    [_user release];
    [_labelsJSON release];
    [_state release];
    
    [super dealloc];
}

@end
