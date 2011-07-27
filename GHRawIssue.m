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
    rawDictionary = GHAPIObjectExpectedClass(rawDictionary, NSDictionary.class);
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


#pragma mark - Keyed Archiving

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:_gravatarID forKey:@"gravatarID"];
    [encoder encodeObject:_position forKey:@"position"];
    [encoder encodeObject:_number forKey:@"number"];
    [encoder encodeObject:_votes forKey:@"votes"];
    [encoder encodeObject:_creationDate forKey:@"creationDate"];
    [encoder encodeObject:_comments forKey:@"comments"];
    [encoder encodeObject:_body forKey:@"body"];
    [encoder encodeObject:_title forKey:@"title"];
    [encoder encodeObject:_updatedAd forKey:@"updatedAd"];
    [encoder encodeObject:_closedAd forKey:@"closedAd"];
    [encoder encodeObject:_user forKey:@"user"];
    [encoder encodeObject:_labelsJSON forKey:@"labelsJSON"];
    [encoder encodeObject:_state forKey:@"state"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super init])) {
        _gravatarID = [decoder decodeObjectForKey:@"gravatarID"];
        _position = [decoder decodeObjectForKey:@"position"];
        _number = [decoder decodeObjectForKey:@"number"];
        _votes = [decoder decodeObjectForKey:@"votes"];
        _creationDate = [decoder decodeObjectForKey:@"creationDate"];
        _comments = [decoder decodeObjectForKey:@"comments"];
        _body = [decoder decodeObjectForKey:@"body"];
        _title = [decoder decodeObjectForKey:@"title"];
        _updatedAd = [decoder decodeObjectForKey:@"updatedAd"];
        _closedAd = [decoder decodeObjectForKey:@"closedAd"];
        _user = [decoder decodeObjectForKey:@"user"];
        _labelsJSON = [decoder decodeObjectForKey:@"labelsJSON"];
        _state = [decoder decodeObjectForKey:@"state"];
    }
    return self;
}

@end
