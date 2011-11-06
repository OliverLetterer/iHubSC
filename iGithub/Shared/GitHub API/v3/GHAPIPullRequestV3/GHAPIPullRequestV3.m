//
//  GHAPIPullRequestV3.m
//  iGithub
//
//  Created by Oliver Letterer on 05.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GithubAPI.h"



@implementation GHAPIPullRequestV3
@synthesize ID = _ID, state = _state, title = _title, body = _body, createdAt = _createdAt, updatedAt = _updatedAt, closedAt = _closedAt, mergedAt = _mergedAt, merged = _merged, isMergable = _isMergable, mergedBy = _mergedBy, comments = _comments, commits = _commits, additions = _additions, deletions = _deletions, changedFiles = _changedFiles, user=_user;

#pragma mark - Initialization

- (id)initWithRawDictionary:(NSDictionary *)rawDictionary
{
    GHAPIObjectExpectedClass(&rawDictionary, NSDictionary.class);
    if (self = [super init]) {
        _ID = [rawDictionary objectForKeyOrNilOnNullObject:@"number"];
        _state = [rawDictionary objectForKeyOrNilOnNullObject:@"state"];
        _title = [rawDictionary objectForKeyOrNilOnNullObject:@"title"];
        _body = [rawDictionary objectForKeyOrNilOnNullObject:@"body"];
        _createdAt = [rawDictionary objectForKeyOrNilOnNullObject:@"created_at"];
        _updatedAt = [rawDictionary objectForKeyOrNilOnNullObject:@"updated_at"];
        _closedAt = [rawDictionary objectForKeyOrNilOnNullObject:@"closed_at"];
        _mergedAt = [rawDictionary objectForKeyOrNilOnNullObject:@"merged_at"];
        _merged = [rawDictionary objectForKeyOrNilOnNullObject:@"merged"];
        _isMergable = [rawDictionary objectForKeyOrNilOnNullObject:@"mergeable"];
        _mergedBy = [[GHAPIUserV3 alloc] initWithRawDictionary:[rawDictionary objectForKeyOrNilOnNullObject:@"merged_by"] ];
        _comments = [rawDictionary objectForKeyOrNilOnNullObject:@"comments"];
        _commits = [rawDictionary objectForKeyOrNilOnNullObject:@"commits"];
        _additions = [rawDictionary objectForKeyOrNilOnNullObject:@"additions"];
        _deletions = [rawDictionary objectForKeyOrNilOnNullObject:@"deletions"];
        _changedFiles = [rawDictionary objectForKeyOrNilOnNullObject:@"changed_files"];
        
        id rawUserDictionary = [rawDictionary objectForKeyOrNilOnNullObject:@"user"];
        _user = [[GHAPIUserV3 alloc] initWithRawDictionary:rawUserDictionary];
    }
    return self;
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)encoder 
{
    [encoder encodeObject:_ID forKey:@"iD"];
    [encoder encodeObject:_state forKey:@"state"];
    [encoder encodeObject:_title forKey:@"title"];
    [encoder encodeObject:_body forKey:@"body"];
    [encoder encodeObject:_createdAt forKey:@"createdAt"];
    [encoder encodeObject:_updatedAt forKey:@"updatedAt"];
    [encoder encodeObject:_closedAt forKey:@"closedAt"];
    [encoder encodeObject:_mergedAt forKey:@"mergedAt"];
    [encoder encodeObject:_merged forKey:@"merged"];
    [encoder encodeObject:_isMergable forKey:@"isMergable"];
    [encoder encodeObject:_mergedBy forKey:@"mergedBy"];
    [encoder encodeObject:_comments forKey:@"comments"];
    [encoder encodeObject:_commits forKey:@"commits"];
    [encoder encodeObject:_additions forKey:@"additions"];
    [encoder encodeObject:_deletions forKey:@"deletions"];
    [encoder encodeObject:_changedFiles forKey:@"changedFiles"];
    [encoder encodeObject:_user forKey:@"user"];
}

- (id)initWithCoder:(NSCoder *)decoder 
{
    if ((self = [super init])) {
        _ID = [decoder decodeObjectForKey:@"iD"];
        _state = [decoder decodeObjectForKey:@"state"];
        _title = [decoder decodeObjectForKey:@"title"];
        _body = [decoder decodeObjectForKey:@"body"];
        _createdAt = [decoder decodeObjectForKey:@"createdAt"];
        _updatedAt = [decoder decodeObjectForKey:@"updatedAt"];
        _closedAt = [decoder decodeObjectForKey:@"closedAt"];
        _mergedAt = [decoder decodeObjectForKey:@"mergedAt"];
        _merged = [decoder decodeObjectForKey:@"merged"];
        _isMergable = [decoder decodeObjectForKey:@"isMergable"];
        _mergedBy = [decoder decodeObjectForKey:@"mergedBy"];
        _comments = [decoder decodeObjectForKey:@"comments"];
        _commits = [decoder decodeObjectForKey:@"commits"];
        _additions = [decoder decodeObjectForKey:@"additions"];
        _deletions = [decoder decodeObjectForKey:@"deletions"];
        _changedFiles = [decoder decodeObjectForKey:@"changedFiles"];
        _user = [decoder decodeObjectForKey:@"user"];
    }
    return self;
}

#pragma mark - Class methods

+ (void)pullRequestsOnRepository:(NSString *)repository 
                            page:(NSUInteger)page 
               completionHandler:(GHAPIPaginationHandler)handler
{
    // v3: GET /repos/:user/:repo/pulls
    
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.github.com/repos/%@/pulls",
                                       [repository stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ] ];
    
    [[GHAPIBackgroundQueueV3 sharedInstance] sendRequestToURL:URL page:page setupHandler:nil 
                                  completionPaginationHandler:^(id object, NSError *error, ASIFormDataRequest *request, NSUInteger nextPage) {
                                      if (error) {
                                          handler(nil, GHAPIPaginationNextPageNotFound, error);
                                      } else {
                                          NSArray *rawArray = GHAPIObjectExpectedClass(&object, NSArray.class);
                                          
                                          NSMutableArray *finalArray = [NSMutableArray arrayWithCapacity:rawArray.count];
                                          for (NSDictionary *rawDictionary in rawArray) {
                                              [finalArray addObject:[[GHAPIPullRequestV3 alloc] initWithRawDictionary:rawDictionary] ];
                                          }
                                          
                                          handler(finalArray, nextPage, nil);
                                      }
                                  }];
}

+ (void)mergPullRequestOnRepository:(NSString *)repository 
                         withNumber:(NSNumber *)pullRequestNumber 
                      commitMessage:(NSString *)commitMessage 
                  completionHandler:(void(^)(GHAPIPullRequestMergeStateV3 *state, NSError *error))handler 
{
    // v3: PUT /repos/:user/:repo/pulls/:id/merge
    
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.github.com/repos/%@/pulls/%@/merge",
                                       [repository stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                                       pullRequestNumber ]];
    
    [[GHAPIBackgroundQueueV3 sharedInstance] sendRequestToURL:URL 
                                            setupHandler:^(ASIFormDataRequest *request) {
                                                [request setRequestMethod:@"PUT"];
                                                
                                                NSDictionary *jsonDictionary = [NSDictionary dictionaryWithObject:commitMessage 
                                                                                                           forKey:@"commit_message"];
                                                
                                                NSString *jsonString = [jsonDictionary JSONString];
                                                NSMutableData *jsonData = [[jsonString dataUsingEncoding:NSUTF8StringEncoding] mutableCopy];
                                                [request setPostBody:jsonData];
                                                [request setPostLength:[jsonString length] ];
                                            }
                                       completionHandler:^(id object, NSError *error, ASIFormDataRequest *request) {
                                           if (error) {
                                               handler(nil, error);
                                           } else {
                                               handler([[GHAPIPullRequestMergeStateV3 alloc] initWithRawDictionary:object], nil);
                                           }
                                       }];
}

+ (void)commitsOfPullRequestOnRepository:(NSString *)repository 
                              withNumber:(NSNumber *)pullRequestNumber 
                       completionHandler:(void(^)(NSArray *commits, NSError *error))completionHandler
{
    // v3: GET /repos/:user/:repo/pulls/:id/commits
    
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.github.com/repos/%@/pulls/%@/commits",
                                       [repository stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                                       pullRequestNumber ]];
    
    [[GHAPIBackgroundQueueV3 sharedInstance] sendRequestToURL:URL 
                                                 setupHandler:nil
                                            completionHandler:^(id object, NSError *error, ASIFormDataRequest *request) {
                                                if (error) {
                                                    completionHandler(nil, error);
                                                } else {
                                                    NSArray *rawArray = GHAPIObjectExpectedClass(&object, NSArray.class);
                                                    
                                                    NSMutableArray *finalArray = [NSMutableArray arrayWithCapacity:rawArray.count];
                                                    for (NSDictionary *rawDictionary in rawArray) {
                                                        [finalArray addObject:[[GHAPICommitV3 alloc] initWithRawDictionary:rawDictionary] ];
                                                    }
                                                    
                                                    completionHandler(finalArray, nil);
                                                }
                                            }];
}

@end
