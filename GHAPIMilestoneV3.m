//
//  GHAPIMilestoneV3.m
//  iGithub
//
//  Created by Oliver Letterer on 30.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHAPIMilestoneV3.h"
#import "GithubAPI.h"

@implementation GHAPIMilestoneV3

@synthesize closedIssues=_closedIssues, createdAt=_createdAt, creator=_creator, milestoneDescription=_milestoneDescription, dueOn=_dueOn, number=_number, openIssues=_openIssues, state=_state, title=_title, URL=_URL;

- (CGFloat)progress {
    return [self.closedIssues floatValue] / ([self.closedIssues floatValue] + [self.openIssues floatValue]);
}

- (NSString *)dueFormattedString {
    if (!self.dueOn) {
        return NSLocalizedString(@"No due date", @"");
    }
    
    NSDate *pastDate = self.dueOn.dateFromGithubAPIDateString;
    
    NSString *timeString = pastDate.prettyTimeIntervalSinceNow;
    
    if (self.dueInTime) {
        return [NSString stringWithFormat:NSLocalizedString(@"Due in %@", @""), timeString];
    }
    
    return [NSString stringWithFormat:NSLocalizedString(@"Past due by %@", @""), timeString];
}

- (BOOL)dueInTime {
    NSDate *pastDate = self.dueOn.dateFromGithubAPIDateString;
    
    return [pastDate timeIntervalSinceNow] > 0 || !self.dueOn;
}

#pragma mark - Initialization

- (id)initWithRawDictionary:(NSDictionary *)rawDictionary {
    rawDictionary = NSObjectExpectedClass(rawDictionary, NSDictionary.class);
    if ((self = [super init])) {
        // Initialization code
        self.closedIssues = [rawDictionary objectForKeyOrNilOnNullObject:@"closed_issues"];
        self.createdAt = [rawDictionary objectForKeyOrNilOnNullObject:@"created_at"];
        self.milestoneDescription = [rawDictionary objectForKeyOrNilOnNullObject:@"description"];
        self.dueOn = [rawDictionary objectForKeyOrNilOnNullObject:@"due_on"];
        self.number = [rawDictionary objectForKeyOrNilOnNullObject:@"number"];
        self.openIssues = [rawDictionary objectForKeyOrNilOnNullObject:@"open_issues"];
        self.state = [rawDictionary objectForKeyOrNilOnNullObject:@"state"];
        self.title = [rawDictionary objectForKeyOrNilOnNullObject:@"title"];
        self.URL = [rawDictionary objectForKeyOrNilOnNullObject:@"url"];
        self.creator = [[[GHAPIUserV3 alloc] initWithRawDictionary:[rawDictionary objectForKeyOrNilOnNullObject:@"creator"] ] autorelease];
    }
    return self;
}

#pragma mark - Memory management

- (void)dealloc {
    [_closedIssues release];
    [_createdAt release];
    [_creator release];
    [_milestoneDescription release];
    [_dueOn release];
    [_number release];
    [_openIssues release];
    [_state release];
    [_title release];
    [_URL release];
    
    [super dealloc];
}

#pragma mark - Keyed Archiving

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:_closedIssues forKey:@"closedIssues"];
    [encoder encodeObject:_createdAt forKey:@"createdAt"];
    [encoder encodeObject:_creator forKey:@"creator"];
    [encoder encodeObject:_milestoneDescription forKey:@"milestoneDescription"];
    [encoder encodeObject:_dueOn forKey:@"dueOn"];
    [encoder encodeObject:_number forKey:@"number"];
    [encoder encodeObject:_openIssues forKey:@"openIssues"];
    [encoder encodeObject:_state forKey:@"state"];
    [encoder encodeObject:_title forKey:@"title"];
    [encoder encodeObject:_URL forKey:@"uRL"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super init])) {
        _closedIssues = [[decoder decodeObjectForKey:@"closedIssues"] retain];
        _createdAt = [[decoder decodeObjectForKey:@"createdAt"] retain];
        _creator = [[decoder decodeObjectForKey:@"creator"] retain];
        _milestoneDescription = [[decoder decodeObjectForKey:@"milestoneDescription"] retain];
        _dueOn = [[decoder decodeObjectForKey:@"dueOn"] retain];
        _number = [[decoder decodeObjectForKey:@"number"] retain];
        _openIssues = [[decoder decodeObjectForKey:@"openIssues"] retain];
        _state = [[decoder decodeObjectForKey:@"state"] retain];
        _title = [[decoder decodeObjectForKey:@"title"] retain];
        _URL = [[decoder decodeObjectForKey:@"uRL"] retain];
    }
    return self;
}

#pragma mark - downloading

+ (void)milestoneOnRepository:(NSString *)repository number:(NSNumber *)number 
            completionHandler:(void(^)(GHAPIMilestoneV3 *milestone, NSError *error))handler {
    
    // v3: GET /repos/:user/:repo/milestones/:id
    
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.github.com/repos/%@/milestones/%@",
                                       [repository stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                                       number]];
    
    [[GHAPIBackgroundQueueV3 sharedInstance] sendRequestToURL:URL setupHandler:nil completionHandler:^(id object, NSError *error, ASIFormDataRequest *request) {
        if (error) {
            handler(nil, error);
        } else {
            handler([[[GHAPIMilestoneV3 alloc] initWithRawDictionary:object] autorelease], nil);
        }
    }];
}

@end
