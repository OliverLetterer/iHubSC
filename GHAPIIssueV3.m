//
//  GHAPIIssueV3.m
//  iGithub
//
//  Created by Oliver Letterer on 30.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHAPIIssueV3.h"
#import "GithubAPI.h"

NSString *const kGHAPIIssueStateV3Open = @"open";
NSString *const kGHAPIIssueStateV3Closed = @"closed";

@implementation GHAPIIssueV3

@synthesize assignee=_assignee, body=_body, attributedBody=_attributedBody, closedAt=_closedAt, comments=_comments, createdAt=_createdAt, HTMLURL=_HTMLURL, labels=_labels, milestone=_milestone, number=_number, pullRequestID=_pullRequestID, state=_state, title=_title, updatedAt=_updatedAt, URL=_URL, user=_user, repository=_repository;

#pragma mark - setters and getters

- (BOOL)isPullRequest {
    return self.pullRequestID != nil;
}

- (BOOL)hasAssignee {
    return self.assignee.login != nil;
}

- (BOOL)hasMilestone {
    return self.milestone.number != nil;
}

#pragma mark - Initialization

- (id)initWithRawDictionary:(NSDictionary *)rawDictionay {
    if ((self = [super init])) {
        // Initialization code
        self.assignee = [[[GHAPIUserV3 alloc] initWithRawDictionary:[rawDictionay objectForKeyOrNilOnNullObject:@"assignee"] ] autorelease];
        self.body = [rawDictionay objectForKeyOrNilOnNullObject:@"body"];
        self.attributedBody = self.body.attributesStringFromMarkdownString;
        self.closedAt = [rawDictionay objectForKeyOrNilOnNullObject:@"closed_at"];
        self.comments = [rawDictionay objectForKeyOrNilOnNullObject:@"comments"];
        self.createdAt = [rawDictionay objectForKeyOrNilOnNullObject:@"created_at"];
        self.HTMLURL = [rawDictionay objectForKeyOrNilOnNullObject:@"html_url"];
        self.number = [rawDictionay objectForKeyOrNilOnNullObject:@"number"];
        self.state = [rawDictionay objectForKeyOrNilOnNullObject:@"state"];
        self.title = [rawDictionay objectForKeyOrNilOnNullObject:@"title"];
        self.updatedAt = [rawDictionay objectForKeyOrNilOnNullObject:@"updated_at"];
        self.URL = [rawDictionay objectForKeyOrNilOnNullObject:@"url"];
        self.user = [[[GHAPIUserV3 alloc] initWithRawDictionary:[rawDictionay objectForKeyOrNilOnNullObject:@"user"] ] autorelease];
        self.repository = [self.URL substringBetweenLeftBounds:@"repos/" andRightBounds:@"/issues"];
        
        self.milestone = [[[GHAPIMilestoneV3 alloc] initWithRawDictionary:[rawDictionay objectForKeyOrNilOnNullObject:@"milestone"] ] autorelease];
        NSString *htmlURL = [[rawDictionay objectForKeyOrNilOnNullObject:@"pull_request"] objectForKeyOrNilOnNullObject:@"html_url"];
        self.pullRequestID = [[htmlURL componentsSeparatedByString:@"/"] lastObject];
        
        NSArray *rawArray = [rawDictionay objectForKeyOrNilOnNullObject:@"labels"];
        NSMutableArray *finalArray = [NSMutableArray arrayWithCapacity:rawArray.count];
        [rawArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [finalArray addObject:[[[GHAPILabelV3 alloc] initWithRawDictionary:obj] autorelease] ];
        }];
        self.labels = finalArray;
    }
    return self;
}

#pragma mark - Memory management

- (void)dealloc {
    [_assignee release];
    [_body release];
    [_attributedBody release];
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
    [_repository release];
    
    [super dealloc];
}

#pragma mark Keyed Archiving

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:_assignee forKey:@"assignee"];
    [encoder encodeObject:_body forKey:@"body"];
    [encoder encodeObject:_attributedBody forKey:@"attributedBody"];
    [encoder encodeObject:_closedAt forKey:@"closedAt"];
    [encoder encodeObject:_comments forKey:@"comments"];
    [encoder encodeObject:_createdAt forKey:@"createdAt"];
    [encoder encodeObject:_HTMLURL forKey:@"hTMLURL"];
    [encoder encodeObject:_labels forKey:@"labels"];
    [encoder encodeObject:_milestone forKey:@"milestone"];
    [encoder encodeObject:_number forKey:@"number"];
    [encoder encodeObject:_pullRequestID forKey:@"pullRequestID"];
    [encoder encodeObject:_state forKey:@"state"];
    [encoder encodeObject:_title forKey:@"title"];
    [encoder encodeObject:_updatedAt forKey:@"updatedAt"];
    [encoder encodeObject:_URL forKey:@"uRL"];
    [encoder encodeObject:_user forKey:@"user"];
    [encoder encodeObject:_repository forKey:@"repository"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super init])) {
        _assignee = [[decoder decodeObjectForKey:@"assignee"] retain];
        _body = [[decoder decodeObjectForKey:@"body"] retain];
        _attributedBody = [[decoder decodeObjectForKey:@"attributedBody"] retain];
        _closedAt = [[decoder decodeObjectForKey:@"closedAt"] retain];
        _comments = [[decoder decodeObjectForKey:@"comments"] retain];
        _createdAt = [[decoder decodeObjectForKey:@"createdAt"] retain];
        _HTMLURL = [[decoder decodeObjectForKey:@"hTMLURL"] retain];
        _labels = [[decoder decodeObjectForKey:@"labels"] retain];
        _milestone = [[decoder decodeObjectForKey:@"milestone"] retain];
        _number = [[decoder decodeObjectForKey:@"number"] retain];
        _pullRequestID = [[decoder decodeObjectForKey:@"pullRequestID"] retain];
        _state = [[decoder decodeObjectForKey:@"state"] retain];
        _title = [[decoder decodeObjectForKey:@"title"] retain];
        _updatedAt = [[decoder decodeObjectForKey:@"updatedAt"] retain];
        _URL = [[decoder decodeObjectForKey:@"uRL"] retain];
        _user = [[decoder decodeObjectForKey:@"user"] retain];
        _repository = [[decoder decodeObjectForKey:@"repository"] retain];
    }
    return self;
}

#pragma mark - class methods

+ (void)openedIssuesOnRepository:(NSString *)repository page:(NSInteger)page completionHandler:(GHAPIPaginationHandler)handler {
    
    // v3: GET /repos/:user/:repo/issues
    
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.github.com/repos/%@/issues",
                                       [repository stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], page ] ];
    
    [[GHAPIBackgroundQueueV3 sharedInstance] sendRequestToURL:URL page:page setupHandler:nil 
                             completionPaginationHandler:^(id object, NSError *error, ASIFormDataRequest *request, NSUInteger nextPage) {
                                 if (error) {
                                     handler(nil, GHAPIPaginationNextPageNotFound, error);
                                 } else {
                                     NSArray *rawArray = object;
                                     
                                     NSMutableArray *finalArray = [NSMutableArray arrayWithCapacity:rawArray.count];
                                     for (NSDictionary *rawDictionary in rawArray) {
                                         [finalArray addObject:[[[GHAPIIssueV3 alloc] initWithRawDictionary:rawDictionary] autorelease] ];
                                     }
                                     
                                     handler(finalArray, nextPage, nil);
                                 }
                             }];
}

+ (void)issueOnRepository:(NSString *)repository 
               withNumber:(NSNumber *)number 
        completionHandler:(void (^)(GHAPIIssueV3 *issue, NSError *error))handler {
    
    // v3: GET /repos/:user/:repo/issues/:id
    
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.github.com/repos/%@/issues/%@",
                                       [repository stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                                       number]];
    
    [[GHAPIBackgroundQueueV3 sharedInstance] sendRequestToURL:URL setupHandler:nil completionHandler:^(id object, NSError *error, ASIFormDataRequest *request) {
        if (error) {
            handler(nil, error);
        } else {
            handler([[[GHAPIIssueV3 alloc] initWithRawDictionary:object] autorelease], nil);
        }
    }];
}

+ (void)milestonesForIssueOnRepository:(NSString *)repository 
                            withNumber:(NSNumber *)number 
                                  page:(NSInteger)page
                     completionHandler:(GHAPIPaginationHandler)handler {
    // v3: /repos/:user/:repo/milestones
    
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.github.com/repos/%@/milestones",
                                       [repository stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ] ];
    
    [[GHAPIBackgroundQueueV3 sharedInstance] sendRequestToURL:URL page:page setupHandler:nil 
                             completionPaginationHandler:^(id object, NSError *error, ASIFormDataRequest *request, NSUInteger nextPage) {
                                 if (error) {
                                     handler(nil, GHAPIPaginationNextPageNotFound, error);
                                 } else {
                                     NSArray *rawArray = object;
                                     
                                     NSMutableArray *finalArray = [NSMutableArray arrayWithCapacity:rawArray.count];
                                     for (NSDictionary *rawDictionary in rawArray) {
                                         [finalArray addObject:[[[GHAPIMilestoneV3 alloc] initWithRawDictionary:rawDictionary] autorelease] ];
                                     }
                                     
                                     handler(finalArray, nextPage, nil);
                                 }
                             }];
}

+ (void)createIssueOnRepository:(NSString *)repository 
                          title:(NSString *)title 
                           body:(NSString *)body 
                       assignee:(NSString *)assignee 
                      milestone:(NSNumber *)milestone 
              completionHandler:(void (^)(GHAPIIssueV3 *issue, NSError *error))handler {
    
    // v3: POST /repos/:user/:repo/issues
    
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.github.com/repos/%@/issues",
                                       [repository stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ] ];
    
    [[GHAPIBackgroundQueueV3 sharedInstance] sendRequestToURL:URL 
                                            setupHandler:^(ASIFormDataRequest *request) {
                                                NSMutableDictionary *jsonDictionary = [NSMutableDictionary dictionaryWithCapacity:4];
                                                if (title) {
                                                    [jsonDictionary setObject:title forKey:@"title"];
                                                }
                                                if (body) {
                                                    [jsonDictionary setObject:body forKey:@"body"];
                                                }
                                                if (assignee) {
                                                    [jsonDictionary setObject:assignee forKey:@"assignee"];
                                                }
                                                if (milestone) {
                                                    [jsonDictionary setObject:milestone forKey:@"milestone"];
                                                }
                                                NSString *jsonString = [jsonDictionary JSONString];
                                                NSMutableData *jsonData = [[[jsonString dataUsingEncoding:NSUTF8StringEncoding] mutableCopy] autorelease];
                                                [request setPostBody:jsonData];
                                                [request setPostLength:[jsonString length] ];
                                            } 
                                       completionHandler:^(id object, NSError *error, ASIFormDataRequest *request) {
                                           if (error) {
                                               handler(nil, error);
                                           } else {
                                               NSDictionary *dictionary = object;
                                               handler([[[GHAPIIssueV3 alloc] initWithRawDictionary:dictionary ] autorelease], nil);
                                           }
                                       }];
}

+ (void)commentsForIssueOnRepository:(NSString *)repository 
                          withNumber:(NSNumber *)number 
                   completionHandler:(void (^)(NSArray *comments, NSError *error))handler {
    
    // v3: GET /repos/:user/:repo/issues/:id/comments
    
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.github.com/repos/%@/issues/%@/comments",
                                       [repository stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], number ] ];
    
    
    [[GHAPIBackgroundQueueV3 sharedInstance] sendRequestToURL:URL setupHandler:nil completionHandler:^(id object, NSError *error, ASIFormDataRequest *request) {
        if (error) {
            handler(nil, error);
        } else {
            NSArray *rawCommentsArray = object;
            
            NSMutableArray *array = [NSMutableArray arrayWithCapacity:rawCommentsArray.count];
            for (NSDictionary *rawDictionary in rawCommentsArray) {
                [array addObject:[[[GHAPIIssueCommentV3 alloc] initWithRawDictionary:rawDictionary] autorelease] ];
            }
            
            handler(array, nil);
        }
    }];
}

+ (void)postComment:(NSString *)comment forIssueOnRepository:(NSString *)repository 
         withNumber:(NSNumber *)number 
  completionHandler:(void (^)(GHAPIIssueCommentV3 *, NSError *))handler {
    
    // v3: POST /repos/:user/:repo/issues/:id/comments
    
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.github.com/repos/%@/issues/%@/comments",
                                       [repository stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], number ] ];
    
    
    [[GHAPIBackgroundQueueV3 sharedInstance] sendRequestToURL:URL 
                                            setupHandler:^(ASIFormDataRequest *request) { 
                                                // {"body"=>"String"}
                                                NSDictionary *jsonDictionary = [NSDictionary dictionaryWithObject:comment forKey:@"body"];
                                                NSString *jsonString = [jsonDictionary JSONString];
                                                NSMutableData *jsonData = [[[jsonString dataUsingEncoding:NSUTF8StringEncoding] mutableCopy] autorelease];
                                                [request setPostBody:jsonData];
                                                [request setPostLength:[jsonString length] ];
                                            } 
                                       completionHandler:^(id object, NSError *error, ASIFormDataRequest *request) {
                                           if (error) {
                                               handler(nil, error);
                                           } else {
                                               handler([[[GHAPIIssueCommentV3 alloc] initWithRawDictionary:object] autorelease], nil);
                                           }
                                       }];
}

+ (void)closeIssueOnRepository:(NSString *)repository 
                    withNumber:(NSNumber *)number 
             completionHandler:(void (^)(NSError *error))handler {
    
    // v3: PATCH /repos/:user/:repo/issues/:id
    
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.github.com/repos/%@/issues/%@",
                                       [repository stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], number ] ];
    
    
    [[GHAPIBackgroundQueueV3 sharedInstance] sendRequestToURL:URL 
                                            setupHandler:^(ASIFormDataRequest *request) { 
                                                // {"body"=>"String"}
                                                
                                                [request setRequestMethod:@"PATCH"];
                                                
                                                NSDictionary *jsonDictionary = [NSDictionary dictionaryWithObject:@"closed" forKey:@"state"];
                                                NSString *jsonString = [jsonDictionary JSONString];
                                                NSMutableData *jsonData = [[[jsonString dataUsingEncoding:NSUTF8StringEncoding] mutableCopy] autorelease];
                                                
                                                [request setPostBody:jsonData];
                                                [request setPostLength:[jsonString length] ];
                                            } 
                                       completionHandler:^(id object, NSError *error, ASIFormDataRequest *request) {
                                           handler(error);
                                       }];
}

+ (void)reopenIssueOnRepository:(NSString *)repository 
                     withNumber:(NSNumber *)number 
              completionHandler:(void (^)(NSError *error))handler {
    
    // v3: PATCH /repos/:user/:repo/issues/:id
    
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.github.com/repos/%@/issues/%@",
                                       [repository stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], number ] ];
    
    
    [[GHAPIBackgroundQueueV3 sharedInstance] sendRequestToURL:URL 
                                            setupHandler:^(ASIFormDataRequest *request) { 
                                                // {"body"=>"String"}
                                                
                                                [request setRequestMethod:@"PATCH"];
                                                
                                                NSDictionary *jsonDictionary = [NSDictionary dictionaryWithObject:@"open" forKey:@"state"];
                                                NSString *jsonString = [jsonDictionary JSONString];
                                                NSMutableData *jsonData = [[[jsonString dataUsingEncoding:NSUTF8StringEncoding] mutableCopy] autorelease];
                                                
                                                [request setPostBody:jsonData];
                                                [request setPostLength:[jsonString length] ];
                                            } 
                                       completionHandler:^(id object, NSError *error, ASIFormDataRequest *request) {
                                           handler(error);
                                       }];
}

+ (void)eventforIssueWithID:(NSNumber *)issueID OnRepository:(NSString *)repository 
          completionHandler:(void (^)(NSArray *events, NSError *error))handler {
    // v3: GET /repos/:user/:repo/issues/:issue_id/events
    
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.github.com/repos/%@/issues/%@/events",
                                       [repository stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], issueID ] ];
    
    [[GHAPIBackgroundQueueV3 sharedInstance] sendRequestToURL:URL setupHandler:nil completionHandler:^(id object, NSError *error, ASIFormDataRequest *request) {
        if (error) {
            handler(nil, error);
        } else {
            NSArray *rawArray = object;
            
            NSMutableArray *finalArray = [NSMutableArray arrayWithCapacity:rawArray.count];
            for (NSDictionary *rawDictionary in rawArray) {
                [finalArray addObject:[[[GHAPIIssueEventV3 alloc] initWithRawDictionary:rawDictionary] autorelease] ];
            }
            
            handler(finalArray, nil);
        }
    }];
}

+ (void)historyForIssueWithID:(NSNumber *)issueID onRepository:(NSString *)repository 
            completionHandler:(void (^)(NSMutableArray *history, NSError *error))handler {
    
    [self commentsForIssueOnRepository:repository withNumber:issueID 
                     completionHandler:^(NSArray *comments, NSError *error) {
                         if (error) {
                             handler(nil, error);
                         } else {
                             [self eventforIssueWithID:issueID OnRepository:repository 
                                     completionHandler:^(NSArray *events, NSError *error) {
                                         if (error) {
                                             handler(nil, error);
                                         } else {
                                             NSMutableArray *final = [NSMutableArray arrayWithCapacity:events.count + comments.count];
                                             
                                             [final addObjectsFromArray:comments];
                                             [final addObjectsFromArray:events];
                                             
                                             [final sortUsingSelector:@selector(compare:)];
                                             
                                             handler(final, nil);
                                         }
                                     }];
                         }
                     }];
}

+ (void)issuesOnRepository:(NSString *)repository 
                 milestone:(NSNumber *)milestone 
                    labels:(NSArray *)labels 
                     state:(NSString *)state 
                      page:(NSInteger)page
         completionHandler:(GHAPIPaginationHandler)handler {
    
    // v3: GET /repos/:user/:repo/issues
    
    NSMutableString *URLString = [NSMutableString stringWithFormat:@"https://api.github.com/repos/%@/issues?",
                                  [repository stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], page ];
    
    BOOL needsAnd = NO;
    
    if (milestone) {
        [URLString appendFormat:@"%@milestone=%@", needsAnd?@"&":@"", milestone];
        needsAnd = YES;
    }
    if (state) {
        [URLString appendFormat:@"%@state=%@", needsAnd?@"&":@"", [state stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ];
        needsAnd = YES;
    }
    if (labels.count > 0) {
        [URLString appendFormat:@"%@labels=%@", needsAnd?@"&":@"", [[labels objectAtIndex:0] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ];
        [labels enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if (idx > 0) {
                [URLString appendFormat:@",%@", [obj stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ];
            }
        }];
        needsAnd = YES;
    }
    
    NSURL *URL = [NSURL URLWithString:URLString];
    
    [[GHAPIBackgroundQueueV3 sharedInstance] sendRequestToURL:URL page:page setupHandler:nil 
                             completionPaginationHandler:^(id object, NSError *error, ASIFormDataRequest *request, NSUInteger nextPage) {
                                 if (error) {
                                     handler(nil, GHAPIPaginationNextPageNotFound, error);
                                 } else {
                                     NSArray *rawArray = object;
                                     
                                     NSMutableArray *finalArray = [NSMutableArray arrayWithCapacity:rawArray.count];
                                     for (NSDictionary *rawDictionary in rawArray) {
                                         [finalArray addObject:[[[GHAPIIssueV3 alloc] initWithRawDictionary:rawDictionary] autorelease] ];
                                     }
                                     
                                     handler(finalArray, nextPage, nil);
                                 }
                             }];
}

+ (void)issuesOfAuthenticatedUserOnPage:(NSInteger)page completionHandler:(GHAPIPaginationHandler)handler {
    // v3: GET /issues
    
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.github.com/issues"]];
    
    [[GHAPIBackgroundQueueV3 sharedInstance] sendRequestToURL:URL page:page setupHandler:nil 
                             completionPaginationHandler:^(id object, NSError *error, ASIFormDataRequest *request, NSUInteger nextPage) {
                                 if (error) {
                                     handler(nil, GHAPIPaginationNextPageNotFound, error);
                                 } else {
                                     NSArray *rawArray = object;
                                     
                                     NSMutableArray *finalArray = [NSMutableArray arrayWithCapacity:rawArray.count];
                                     for (NSDictionary *rawDictionary in rawArray) {
                                         [finalArray addObject:[[[GHAPIIssueV3 alloc] initWithRawDictionary:rawDictionary] autorelease] ];
                                     }
                                     
                                     handler(finalArray, nextPage, nil);
                                 }
                             }];
}

+ (void)updateIssueOnRepository:(NSString *)repository 
                     withNumber:(NSNumber *)number 
                          title:(NSString *)title 
                           body:(NSString *)body 
                       assignee:(NSString *)assignee 
                          state:(NSString *)state 
                      milestone:(NSNumber *)milestone 
                         labels:(NSArray *)labels 
              completionHandler:(void (^)(GHAPIIssueV3 *issue, NSError *error))handler {
    // PATCH /repos/:user/:repo/issues/:id
    
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.github.com/repos/%@/issues/%@",
                                       [repository stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], number ] ];
    
    
    [[GHAPIBackgroundQueueV3 sharedInstance] sendRequestToURL:URL 
                                                 setupHandler:^(ASIFormDataRequest *request) { 
                                                     [request setRequestMethod:@"PATCH"];
                                                     NSMutableDictionary *jsonDictionary = [NSMutableDictionary dictionaryWithCapacity:6];
                                                     
                                                     if (title) {
                                                         [jsonDictionary setObject:title forKey:@"title"];
                                                     }
                                                     if (body) {
                                                         [jsonDictionary setObject:body forKey:@"body"];
                                                     }
                                                     if (assignee) {
                                                         [jsonDictionary setObject:assignee forKey:@"assignee"];
                                                     }
                                                     if (state) {
                                                         [jsonDictionary setObject:state forKey:@"state"];
                                                     }
                                                     if (milestone) {
                                                         [jsonDictionary setObject:milestone forKey:@"milestone"];
                                                     }
                                                     if (labels) {
                                                         [jsonDictionary setObject:labels forKey:@"labels"];
                                                     }
                                                     NSString *jsonString = [jsonDictionary JSONString];
                                                     NSMutableData *jsonData = [[[jsonString dataUsingEncoding:NSUTF8StringEncoding] mutableCopy] autorelease];
                                                     
                                                     [request setPostBody:jsonData];
                                                     [request setPostLength:[jsonString length] ];
                                                 } 
                                            completionHandler:^(id object, NSError *error, ASIFormDataRequest *request) {
                                                if (error) {
                                                    handler(nil, error);
                                                } else {
                                                    handler([[[GHAPIIssueV3 alloc] initWithRawDictionary:object] autorelease], nil);
                                                }
                                            }];
}

@end
