//
//  GHIssueV3.m
//  iGithub
//
//  Created by Oliver Letterer on 30.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHIssueV3.h"
#import "GithubAPI.h"

@implementation GHIssueV3

@synthesize assignee=_assignee, body=_body, closedAt=_closedAt, comments=_comments, createdAt=_createdAt, HTMLURL=_HTMLURL, labels=_labels, milestone=_milestone, number=_number, pullRequestID=_pullRequestID, state=_state, title=_title, updatedAt=_updatedAt, URL=_URL, user=_user;

#pragma mark - Initialization

- (id)initWithRawDictionary:(NSDictionary *)rawDictionay {
    if ((self = [super init])) {
        // Initialization code
        self.assignee = [[[GHUser alloc] initWithRawDictionary:[rawDictionay objectForKeyOrNilOnNullObject:@"assignee"] ] autorelease];
        self.body = [rawDictionay objectForKeyOrNilOnNullObject:@"body"];
        self.closedAt = [rawDictionay objectForKeyOrNilOnNullObject:@"closed_at"];
        self.comments = [rawDictionay objectForKeyOrNilOnNullObject:@"comments"];
        self.createdAt = [rawDictionay objectForKeyOrNilOnNullObject:@"created_at"];
        self.HTMLURL = [rawDictionay objectForKeyOrNilOnNullObject:@"html_url"];
        self.labels = [rawDictionay objectForKeyOrNilOnNullObject:@"labels"];
        self.number = [rawDictionay objectForKeyOrNilOnNullObject:@"number"];
        self.state = [rawDictionay objectForKeyOrNilOnNullObject:@"state"];
        self.title = [rawDictionay objectForKeyOrNilOnNullObject:@"title"];
        self.updatedAt = [rawDictionay objectForKeyOrNilOnNullObject:@"updated_at"];
        self.URL = [rawDictionay objectForKeyOrNilOnNullObject:@"url"];
        self.user = [[[GHUser alloc] initWithRawDictionary:[rawDictionay objectForKeyOrNilOnNullObject:@"user"] ] autorelease];
        
        self.milestone = [[[GHMilestone alloc] initWithRawDictionary:[rawDictionay objectForKeyOrNilOnNullObject:@"milestone"] ] autorelease];
        NSString *htmlURL = [[rawDictionay objectForKeyOrNilOnNullObject:@"pull_request"] objectForKeyOrNilOnNullObject:@"html_url"];
        self.pullRequestID = [[htmlURL componentsSeparatedByString:@"/"] lastObject];
    }
    return self;
}

#pragma mark - Memory management

- (void)dealloc {
    [_assignee release];
    [_body release];
    [_closedAt release];
    [_comments release];
    [_createdAt release];
    [_HTMLURL release];
    [_labels release];
    [_milestone release];
    [_number release];
    [_pullRequestID release];
    [_state release];
    [_title release];
    [_updatedAt release];
    [_URL release];
    [_user release];
    
    [super dealloc];
}

#pragma mark - class methods

+ (void)openedIssuesOnRepository:(NSString *)repository 
                            page:(NSInteger)page
               completionHandler:(void (^)(NSArray *issues, NSInteger nextPage, NSError *error))handler {
    
    // v3: https://api.github.com/repos/docmorelli/Installous/issues.json
    
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.github.com/repos/%@/issues.json?page=%d",
                                       [repository stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], page ] ];
    
    [[GHBackgroundQueue sharedInstance] sendRequestToURL:URL setupHandler:nil completionHandler:^(id object, NSError *error, ASIFormDataRequest *request) {
        if (error) {
            handler(nil, 0, error);
        } else {
            NSArray *rawArray = object;
            
            NSMutableArray *finalArray = [NSMutableArray arrayWithCapacity:rawArray.count];
            for (NSDictionary *rawDictionary in rawArray) {
                [finalArray addObject:[[[GHIssueV3 alloc] initWithRawDictionary:rawDictionary] autorelease] ];
            }
            
            NSString *XNext = [[request responseHeaders] objectForKey:@"X-Next"];
            NSInteger nextPage = 0;
            
            if (XNext) {
                NSString *page = [[XNext componentsSeparatedByString:@"page="] lastObject];
                nextPage = [page intValue];
            }
            
            handler(finalArray, nextPage, nil);
        }
    }];
}

@end
