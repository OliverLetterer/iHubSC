//
//  GHAPIIssueV3.m
//  iGithub
//
//  Created by Oliver Letterer on 30.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHAPIIssueV3.h"
#import "GithubAPI.h"
#import "NSAttributedString+HTML.h"

NSString *const GHAPIIssueV3ContentChangedNotification = @"GHAPIIssueV3ContentChangedNotification";
NSString *const GHAPIIssueV3CreationNotification = @"GHAPIIssueV3CreationNotification";



NSString *const kGHAPIIssueStateV3Open = @"open";
NSString *const kGHAPIIssueStateV3Closed = @"closed";

@implementation GHAPIIssueV3

@synthesize assignee=_assignee, body=_body, attributedBody=_attributedBody, selectedAttributedBody=_selectedAttributedBody, closedAt=_closedAt, comments=_comments, createdAt=_createdAt, HTMLURL=_HTMLURL, labels=_labels, milestone=_milestone, number=_number, pullRequestID=_pullRequestID, state=_state, title=_title, updatedAt=_updatedAt, URL=_URL, user=_user, repository=_repository;

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

- (BOOL)isOpen {
    return [self.state isEqualToString:kGHAPIIssueStateV3Open];
}

- (NSAttributedString *)attributedBody {
    if (!_attributedBody) {
        _attributedBody = self.body.nonSelectedAttributesStringFromMarkdown;
    }
    return _attributedBody;
}

- (NSAttributedString *)selectedAttributedBody {
    if (!_selectedAttributedBody) {
        _selectedAttributedBody = self.body.selectedAttributesStringFromMarkdown;
    }
    return _selectedAttributedBody;
}

- (BOOL)matchedString:(NSString *)string {
    if (!string) {
        return NO;
    }
    NSMutableArray *possibleString = [NSMutableArray arrayWithCapacity:10];
    NSString *myString = nil;
    
    myString = self.assignee.login;
    if (myString) {
        [possibleString addObject:myString];
    }
    myString = self.repository;
    if (myString) {
        [possibleString addObject:myString];
    }
    myString = self.title;
    if (myString) {
        [possibleString addObject:myString];
    }
    myString = self.body;
    if (myString) {
        [possibleString addObject:myString];
    }
    myString = self.milestone.title;
    if (myString) {
        [possibleString addObject:myString];
    }
    myString = self.milestone.milestoneDescription;
    if (myString) {
        [possibleString addObject:myString];
    }
    
    for (GHAPILabelV3 *label in self.labels) {
        myString = label.name;
        if (myString) {
            [possibleString addObject:myString];
        }
    }
    
    for (NSString *str in possibleString) {
        if ([str rangeOfString:string options:NSCaseInsensitiveSearch].location != NSNotFound) {
            return YES;
        }
    }
    
    return NO;
}

- (BOOL)isEqualToIssue:(GHAPIIssueV3 *)issue {
    return [self.repository isEqualToString:issue.repository] && [self.number isEqualToNumber:issue.number];
}

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:GHAPIIssueV3.class]) {
        return [self isEqualToIssue:object];
    }
    return NO;
}

#pragma mark - Initialization

- (id)initWithRawDictionary:(NSDictionary *)rawDictionary {
    GHAPIObjectExpectedClass(&rawDictionary, NSDictionary.class);
    if ((self = [super init])) {
        // Initialization code
        self.assignee = [[GHAPIUserV3 alloc] initWithRawDictionary:[rawDictionary objectForKeyOrNilOnNullObject:@"assignee"] ];
        self.body = [rawDictionary objectForKeyOrNilOnNullObject:@"body"];
        self.closedAt = [rawDictionary objectForKeyOrNilOnNullObject:@"closed_at"];
        self.comments = [rawDictionary objectForKeyOrNilOnNullObject:@"comments"];
        self.createdAt = [rawDictionary objectForKeyOrNilOnNullObject:@"created_at"];
        self.HTMLURL = [rawDictionary objectForKeyOrNilOnNullObject:@"html_url"];
        self.number = [rawDictionary objectForKeyOrNilOnNullObject:@"number"];
        self.state = [rawDictionary objectForKeyOrNilOnNullObject:@"state"];
        self.title = [rawDictionary objectForKeyOrNilOnNullObject:@"title"];
        self.updatedAt = [rawDictionary objectForKeyOrNilOnNullObject:@"updated_at"];
        self.URL = [rawDictionary objectForKeyOrNilOnNullObject:@"url"];
        self.user = [[GHAPIUserV3 alloc] initWithRawDictionary:[rawDictionary objectForKeyOrNilOnNullObject:@"user"] ];
        self.repository = [self.URL substringBetweenLeftBounds:@"repos/" andRightBounds:@"/issues"];
        
        self.milestone = [[GHAPIMilestoneV3 alloc] initWithRawDictionary:[rawDictionary objectForKeyOrNilOnNullObject:@"milestone"] ];
        NSString *htmlURL = [[rawDictionary objectForKeyOrNilOnNullObject:@"pull_request"] objectForKeyOrNilOnNullObject:@"html_url"];
        self.pullRequestID = [[htmlURL componentsSeparatedByString:@"/"] lastObject];
        
        NSArray *rawArray = [rawDictionary objectForKeyOrNilOnNullObject:@"labels"];
        NSMutableArray *finalArray = [NSMutableArray arrayWithCapacity:rawArray.count];
        [rawArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [finalArray addObject:[[GHAPILabelV3 alloc] initWithRawDictionary:obj] ];
        }];
        self.labels = finalArray;
    }
    return self;
}

#pragma mark - Keyed Archiving

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:_assignee forKey:@"assignee"];
    [encoder encodeObject:_body forKey:@"body"];
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
        _assignee = [decoder decodeObjectForKey:@"assignee"];
        _body = [decoder decodeObjectForKey:@"body"];
        _closedAt = [decoder decodeObjectForKey:@"closedAt"];
        _comments = [decoder decodeObjectForKey:@"comments"];
        _createdAt = [decoder decodeObjectForKey:@"createdAt"];
        _HTMLURL = [decoder decodeObjectForKey:@"hTMLURL"];
        _labels = [decoder decodeObjectForKey:@"labels"];
        _milestone = [decoder decodeObjectForKey:@"milestone"];
        _number = [decoder decodeObjectForKey:@"number"];
        _pullRequestID = [decoder decodeObjectForKey:@"pullRequestID"];
        _state = [decoder decodeObjectForKey:@"state"];
        _title = [decoder decodeObjectForKey:@"title"];
        _updatedAt = [decoder decodeObjectForKey:@"updatedAt"];
        _URL = [decoder decodeObjectForKey:@"uRL"];
        _user = [decoder decodeObjectForKey:@"user"];
        _repository = [decoder decodeObjectForKey:@"repository"];
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
                                     NSArray *rawArray = GHAPIObjectExpectedClass(&object, NSArray.class);
                                     
                                     NSMutableArray *finalArray = [NSMutableArray arrayWithCapacity:rawArray.count];
                                     for (NSDictionary *rawDictionary in rawArray) {
                                         [finalArray addObject:[[GHAPIIssueV3 alloc] initWithRawDictionary:rawDictionary] ];
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
            handler([[GHAPIIssueV3 alloc] initWithRawDictionary:object], nil);
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
                                     NSArray *rawArray = GHAPIObjectExpectedClass(&object, NSArray.class);
                                     
                                     NSMutableArray *finalArray = [NSMutableArray arrayWithCapacity:rawArray.count];
                                     for (NSDictionary *rawDictionary in rawArray) {
                                         [finalArray addObject:[[GHAPIMilestoneV3 alloc] initWithRawDictionary:rawDictionary] ];
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
                         labels:(NSArray *)labels 
              completionHandler:(void (^)(GHAPIIssueV3 *issue, NSError *error))handler {
    // POST /repos/:user/:repo/issues
    
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.github.com/repos/%@/issues",
                                       [repository stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ] ];
    
    [[GHAPIBackgroundQueueV3 sharedInstance] sendRequestToURL:URL 
                                                 setupHandler:^(ASIFormDataRequest *request) { 
                                                     [request setRequestMethod:@"POST"];
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
                                                     if (milestone) {
                                                         [jsonDictionary setObject:milestone forKey:@"milestone"];
                                                     }
                                                     if (labels) {
                                                         [jsonDictionary setObject:labels forKey:@"labels"];
                                                     }
                                                     NSString *jsonString = [jsonDictionary JSONString];
                                                     NSMutableData *jsonData = [[jsonString dataUsingEncoding:NSUTF8StringEncoding] mutableCopy];
                                                     
                                                     [request setPostBody:jsonData];
                                                     [request setPostLength:[jsonString length] ];
                                                 } 
                                            completionHandler:^(id object, NSError *error, ASIFormDataRequest *request) {
                                                if (error) {
                                                    handler(nil, error);
                                                } else {
                                                    GHAPIIssueV3 *issue = [[GHAPIIssueV3 alloc] initWithRawDictionary:object];
                                                    [[NSNotificationCenter defaultCenter] postNotificationName:GHAPIIssueV3CreationNotification object:nil 
                                                                                                      userInfo:[NSDictionary dictionaryWithObject:issue forKey:GHAPIV3NotificationUserDictionaryIssueKey] ];
                                                    handler(issue, nil);
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
            NSArray *rawCommentsArray = GHAPIObjectExpectedClass(&object, NSArray.class);
            
            NSMutableArray *array = [NSMutableArray arrayWithCapacity:rawCommentsArray.count];
            for (NSDictionary *rawDictionary in rawCommentsArray) {
                [array addObject:[[GHAPIIssueCommentV3 alloc] initWithRawDictionary:rawDictionary] ];
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
                                                NSMutableData *jsonData = [[jsonString dataUsingEncoding:NSUTF8StringEncoding] mutableCopy];
                                                [request setPostBody:jsonData];
                                                [request setPostLength:[jsonString length] ];
                                            } 
                                       completionHandler:^(id object, NSError *error, ASIFormDataRequest *request) {
                                           if (error) {
                                               handler(nil, error);
                                           } else {
                                               handler([[GHAPIIssueCommentV3 alloc] initWithRawDictionary:object], nil);
                                           }
                                       }];
}

+ (void)closeIssueOnRepository:(NSString *)repository 
                    withNumber:(NSNumber *)number 
             completionHandler:(void (^)(NSError *error))handler {
    [self updateIssueOnRepository:repository withNumber:number title:nil body:nil assignee:nil state:kGHAPIIssueStateV3Closed 
                        milestone:nil labels:nil completionHandler:^(GHAPIIssueV3 *issue, NSError *error) {
                            if (error) {
                                handler(error);
                            } else {
                                handler(nil);
                            }
                        }];
}

+ (void)reopenIssueOnRepository:(NSString *)repository 
                     withNumber:(NSNumber *)number 
              completionHandler:(void (^)(NSError *error))handler {
    [self updateIssueOnRepository:repository withNumber:number title:nil body:nil assignee:nil state:kGHAPIIssueStateV3Open 
                        milestone:nil labels:nil completionHandler:^(GHAPIIssueV3 *issue, NSError *error) {
                            if (error) {
                                handler(error);
                            } else {
                                handler(nil);
                            }
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
            NSArray *rawArray = GHAPIObjectExpectedClass(&object, NSArray.class);
            
            NSMutableArray *finalArray = [NSMutableArray arrayWithCapacity:rawArray.count];
            for (NSDictionary *rawDictionary in rawArray) {
                [finalArray addObject:[[GHAPIIssueEventV3 alloc] initWithRawDictionary:rawDictionary] ];
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
                                     NSArray *rawArray = GHAPIObjectExpectedClass(&object, NSArray.class);
                                     
                                     NSMutableArray *finalArray = [NSMutableArray arrayWithCapacity:rawArray.count];
                                     for (NSDictionary *rawDictionary in rawArray) {
                                         [finalArray addObject:[[GHAPIIssueV3 alloc] initWithRawDictionary:rawDictionary] ];
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
                                     NSArray *rawArray = GHAPIObjectExpectedClass(&object, NSArray.class);
                                     
                                     NSMutableArray *finalArray = [NSMutableArray arrayWithCapacity:rawArray.count];
                                     for (NSDictionary *rawDictionary in rawArray) {
                                         [finalArray addObject:[[GHAPIIssueV3 alloc] initWithRawDictionary:rawDictionary] ];
                                     }
                                     
                                     handler(finalArray, nextPage, nil);
                                 }
                             }];
}

+ (void)replaceLabelOfIssueOnRepository:(NSString *)repository 
                                 number:(NSNumber *)number withLabels:(NSArray *)labels completionHandler:(GHAPIErrorHandler)handler {
    // v3: PUT /repos/:user/:repo/issues/:id/labels
    
    if (!labels) {
        handler(nil);
        return;
    }
    
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.github.com/repos/%@/issues/%@/labels",
                                       [repository stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], number ] ];
    
    
    [[GHAPIBackgroundQueueV3 sharedInstance] sendRequestToURL:URL 
                                                 setupHandler:^(ASIFormDataRequest *request) { 
                                                     [request setRequestMethod:@"PUT"];
                                                     
                                                     NSString *jsonString = [labels JSONString];
                                                     NSMutableData *jsonData = [[jsonString dataUsingEncoding:NSUTF8StringEncoding] mutableCopy];
                                                     
                                                     [request setPostBody:jsonData];
                                                     [request setPostLength:[jsonString length] ];
                                                 } 
                                            completionHandler:^(id object, NSError *error, ASIFormDataRequest *request) {
                                                handler(error);
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
    
    [self replaceLabelOfIssueOnRepository:repository number:number withLabels:labels 
                        completionHandler:^(NSError *error) {
                            if (error) {
                                handler(nil, error);
                            } else {
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
                                                                                 NSString *jsonString = [jsonDictionary JSONString];
                                                                                 NSMutableData *jsonData = [[jsonString dataUsingEncoding:NSUTF8StringEncoding] mutableCopy];
                                                                                 
                                                                                 [request setPostBody:jsonData];
                                                                                 [request setPostLength:[jsonString length] ];
                                                                             } 
                                                                        completionHandler:^(id object, NSError *error, ASIFormDataRequest *request) {
                                                                            if (error) {
                                                                                handler(nil, error);
                                                                            } else {
                                                                                GHAPIIssueV3 *issue = [[GHAPIIssueV3 alloc] initWithRawDictionary:object];
                                                                                [[NSNotificationCenter defaultCenter] postNotificationName:GHAPIIssueV3ContentChangedNotification object:nil 
                                                                                                                                  userInfo:[NSDictionary dictionaryWithObject:issue forKey:GHAPIV3NotificationUserDictionaryIssueKey] ];
                                                                                handler(issue, nil);
                                                                            }
                                                                        }];
                            }
                        }];
}

+ (void)allIssuesOfAuthenticatedUserWithCompletionHandler:(void (^)(NSMutableArray *issues, NSError *error))handler {
    NSMutableArray *issues = [NSMutableArray array];
    [self _dumpIssuesOfAuthenticatedUserInArray:issues page:1 completionHandler:^(NSError *error) {
        if (error) {
            handler(nil, error);
        } else {
            handler(issues, nil);
        }
    }];
}

+ (void)_dumpIssuesOfAuthenticatedUserInArray:(NSMutableArray *)issuesArray page:(NSUInteger)page completionHandler:(GHAPIErrorHandler)handler {
    if (page == GHAPIPaginationNextPageNotFound) {
        handler(nil);
    } else {
        [self issuesOfAuthenticatedUserOnPage:page completionHandler:^(NSMutableArray *array, NSUInteger nextPage, NSError *error) {
            if (error) {
                handler(error);
            } else {
                [issuesArray addObjectsFromArray:array];
                [self _dumpIssuesOfAuthenticatedUserInArray:issuesArray page:nextPage completionHandler:handler];
            }
        }];
    }
}

@end
