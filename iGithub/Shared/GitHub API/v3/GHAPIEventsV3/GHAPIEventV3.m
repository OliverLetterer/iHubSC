//
//  GHAPIEventV3.m
//  iGithub
//
//  Created by Oliver Letterer on 02.11.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GithubAPI.h"

NSString *const GHAPIEventV3TypeCommitComment = @"CommitCommentEvent";
NSString *const GHAPIEventV3TypeCreateEvent = @"CreateEvent";
NSString *const GHAPIEventV3TypeDeleteEvent = @"DeleteEvent";
NSString *const GHAPIEventV3TypeDownloadEvent = @"DownloadEvent";
NSString *const GHAPIEventV3TypeFollowEvent = @"FollowEvent";
NSString *const GHAPIEventV3TypeForkEvent = @"ForkEvent";
NSString *const GHAPIEventV3TypeForkApplyEvent = @"ForkApplyEvent";
NSString *const GHAPIEventV3TypeGistEvent = @"GistEvent";
NSString *const GHAPIEventV3TypeGollumEvent = @"GollumEvent";
NSString *const GHAPIEventV3TypeIssueCommentEvent = @"IssueCommentEvent";
NSString *const GHAPIEventV3TypeIssuesEvent = @"IssuesEvent";
NSString *const GHAPIEventV3TypeMemberEvent = @"MemberEvent";
NSString *const GHAPIEventV3TypePublicEvent = @"PublicEvent";
NSString *const GHAPIEventV3TypePullRequestEvent = @"PullRequestEvent";
NSString *const GHAPIEventV3TypePushEvent = @"PushEvent";
NSString *const GHAPIEventV3TypeTeamAddEvent = @"TeamAddEvent";
NSString *const GHAPIEventV3TypeWatchEvent = @"WatchEvent";

GHAPIEventTypeV3 GHAPIEventTypeV3FromNSString(NSString *eventType)
{
    GHAPIEventTypeV3 type = GHAPIEventTypeV3Unkown;
    
    if ([eventType isEqualToString:GHAPIEventV3TypeCommitComment]) {
        type = GHAPIEventTypeV3CommitComment;
    } else if ([eventType isEqualToString:GHAPIEventV3TypeCreateEvent]) {
        type = GHAPIEventTypeV3CreateEvent;
    } else if ([eventType isEqualToString:GHAPIEventV3TypeDeleteEvent]) {
        type = GHAPIEventTypeV3DeleteEvent;
    } else if ([eventType isEqualToString:GHAPIEventV3TypeDownloadEvent]) {
        type = GHAPIEventTypeV3DownloadEvent;
    } else if ([eventType isEqualToString:GHAPIEventV3TypeFollowEvent]) {
        type = GHAPIEventTypeV3FollowEvent;
    } else if ([eventType isEqualToString:GHAPIEventV3TypeForkEvent]) {
        type = GHAPIEventTypeV3ForkEvent;
    } else if ([eventType isEqualToString:GHAPIEventV3TypeForkApplyEvent]) {
        type = GHAPIEventTypeV3ForkApplyEvent;
    } else if ([eventType isEqualToString:GHAPIEventV3TypeGistEvent]) {
        type = GHAPIEventTypeV3GistEvent;
    } else if ([eventType isEqualToString:GHAPIEventV3TypeGollumEvent]) {
        type = GHAPIEventTypeV3GollumEvent;
    } else if ([eventType isEqualToString:GHAPIEventV3TypeIssueCommentEvent]) {
        type = GHAPIEventTypeV3IssueCommentEvent;
    } else if ([eventType isEqualToString:GHAPIEventV3TypeIssuesEvent]) {
        type = GHAPIEventTypeV3IssuesEvent;
    } else if ([eventType isEqualToString:GHAPIEventV3TypeMemberEvent]) {
        type = GHAPIEventTypeV3MemberEvent;
    } else if ([eventType isEqualToString:GHAPIEventV3TypePublicEvent]) {
        type = GHAPIEventTypeV3PublicEvent;
    } else if ([eventType isEqualToString:GHAPIEventV3TypePullRequestEvent]) {
        type = GHAPIEventTypeV3PullRequestEvent;
    } else if ([eventType isEqualToString:GHAPIEventV3TypePushEvent]) {
        type = GHAPIEventTypeV3PushEvent;
    } else if ([eventType isEqualToString:GHAPIEventV3TypeTeamAddEvent]) {
        type = GHAPIEventTypeV3TeamAddEvent;
    } else if ([eventType isEqualToString:GHAPIEventV3TypeWatchEvent]) {
        type = GHAPIEventTypeV3WatchEvent;
    } else {
        type = GHAPIEventTypeV3Unkown;
    }
    
    return type;
}


@implementation GHAPIEventV3
@synthesize repository=_repository, actor=_actor, organization=_organization, createdAtString=_createdAtString, typeString=_typeString, public=_public, type=_type;

#pragma mark - Initialization

- (id)initWithRawPayloadDictionary:(NSDictionary *)rawPayloadDictionary
{
    return [super init];
}

- (id)initWithRawDictionary:(NSDictionary *)rawDictionary
{
    GHAPIObjectExpectedClass(&rawDictionary, NSDictionary.class);
    NSDictionary *rawPayloadDictionary = [rawDictionary objectForKeyOrNilOnNullObject:@"payload"];
    
    if (self = [self initWithRawPayloadDictionary:rawPayloadDictionary]) {
        // Initialization code
        _repository = [[GHAPIRepositoryV3 alloc] initWithRawDictionary:[rawDictionary objectForKeyOrNilOnNullObject:@"repo"]];
        _actor = [[GHAPIUserV3 alloc] initWithRawDictionary:[rawDictionary objectForKeyOrNilOnNullObject:@"actor"]];
        _organization = [[GHAPIOrganizationV3 alloc] initWithRawDictionary:[rawDictionary objectForKeyOrNilOnNullObject:@"org"]];
        
        _createdAtString = [rawDictionary objectForKeyOrNilOnNullObject:@"created_at"];
        _typeString = [rawDictionary objectForKeyOrNilOnNullObject:@"type"];
        _public = [rawDictionary objectForKeyOrNilOnNullObject:@"public"];
        
        _type = GHAPIEventTypeV3FromNSString(_typeString);
        NSAssert(_type != GHAPIEventTypeV3Unkown, @"_typeString (%@) cannot be unkown", _typeString);
    }
    return self;
}

+ (id)eventWithRawDictionary:(NSDictionary *)rawDictionary
{
    GHAPIEventV3 *event = nil;
    
    if (GHAPIObjectExpectedClass(&rawDictionary, NSDictionary.class)) {
        NSString *typeString = [rawDictionary objectForKeyOrNilOnNullObject:@"type"];
        GHAPIEventTypeV3 type = GHAPIEventTypeV3FromNSString(typeString);
        
        switch (type) {
            case GHAPIEventTypeV3CommitComment: {
                event = [[GHAPICommitCommentEventV3 alloc] initWithRawDictionary:rawDictionary];
                break;
            }
            case GHAPIEventTypeV3CreateEvent: {
                event = [[GHAPICreateEventV3 alloc] initWithRawDictionary:rawDictionary];
                break;
            }
            case GHAPIEventTypeV3DeleteEvent: {
                event = [[GHAPIDeleteEventV3 alloc] initWithRawDictionary:rawDictionary];
                break;
            }
            case GHAPIEventTypeV3DownloadEvent: {
                event = [[GHAPIDownloadEventV3 alloc] initWithRawDictionary:rawDictionary];
                break;
            }
            case GHAPIEventTypeV3FollowEvent: {
                event = [[GHAPIFollowEventV3 alloc] initWithRawDictionary:rawDictionary];
                break;
            }
            case GHAPIEventTypeV3ForkEvent: {
                event = [[GHAPIForkEventV3 alloc] initWithRawDictionary:rawDictionary];
                break;
            }
            case GHAPIEventTypeV3ForkApplyEvent: {
                event = [[GHAPIForkApplyEventV3 alloc] initWithRawDictionary:rawDictionary];
                break;
            }
            case GHAPIEventTypeV3GistEvent: {
                event = [[GHAPIGistEventV3 alloc] initWithRawDictionary:rawDictionary];
                break;
            }
            case GHAPIEventTypeV3GollumEvent: {
                event = [[GHAPIGollumEventV3 alloc] initWithRawDictionary:rawDictionary];
                break;
            }
            case GHAPIEventTypeV3IssueCommentEvent: {
                event = [[GHAPIIssueCommentEventV3 alloc] initWithRawDictionary:rawDictionary];
                break;
            }
            case GHAPIEventTypeV3IssuesEvent: {
                event = [[GHAPIIssuesEventV3 alloc] initWithRawDictionary:rawDictionary];
                break;
            }
            case GHAPIEventTypeV3MemberEvent: {
                event = [[GHAPIMemberEventV3 alloc] initWithRawDictionary:rawDictionary];
                break;
            }
            case GHAPIEventTypeV3PublicEvent: {
                event = [[GHAPIPublicEventV3 alloc] initWithRawDictionary:rawDictionary];
                break;
            }
            case GHAPIEventTypeV3PullRequestEvent: {
                event = [[GHAPIPullRequestEventV3 alloc] initWithRawDictionary:rawDictionary];
                break;
            }
            case GHAPIEventTypeV3PushEvent: {
                event = [[GHAPIPushEventV3 alloc] initWithRawDictionary:rawDictionary];
                break;
            }
            case GHAPIEventTypeV3TeamAddEvent: {
                event = [[GHAPITeamAddEventV3 alloc] initWithRawDictionary:rawDictionary];
                break;
            }
            case GHAPIEventTypeV3WatchEvent: {
                event = [[GHAPIWatchEventV3 alloc] initWithRawDictionary:rawDictionary];
                break;
            }
            default:
                NSAssert(NO, @"default case for typeString (%@) and type (%d) is not supported", typeString, type);
                break;
        }
    }
    
    return event;
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:_repository forKey:@"repository"];
    [encoder encodeObject:_actor forKey:@"actor"];
    [encoder encodeObject:_organization forKey:@"organization"];
    [encoder encodeObject:_createdAtString forKey:@"createdAtString"];
    [encoder encodeObject:_typeString forKey:@"typeString"];
    [encoder encodeObject:_public forKey:@"public"];
    [encoder encodeInteger:_type forKey:@"type"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super init])) {
        _repository = [decoder decodeObjectForKey:@"repository"];
        _actor = [decoder decodeObjectForKey:@"actor"];
        _organization = [decoder decodeObjectForKey:@"organization"];
        _createdAtString = [decoder decodeObjectForKey:@"createdAtString"];
        _typeString = [decoder decodeObjectForKey:@"typeString"];
        _public = [decoder decodeObjectForKey:@"public"];
        _type = [decoder decodeIntegerForKey:@"type"];
    }
    return self;
}

#pragma mark - Class methods

+ (void)_dumpEventsForAuthenticatedUserSinceLastEventDateString:(NSString *)lastEventDateString 
                                                 nextPageToDump:(NSUInteger)nextPage 
                                                        inArray:(NSMutableArray *)eventsArray
                                              completionHandler:(void(^)(NSArray *events, NSError *error))completionHandler
{
    if (nextPage == GHAPIPaginationNextPageNotFound) {
        completionHandler(eventsArray, nil);
        return;
    }
    
    NSDate *lastEventDate = lastEventDateString.dateFromGithubAPIDateString;
    NSTimeInterval lastEventTimeIterval = lastEventDate.timeIntervalSince1970;
    
    [self eventsForAuthenticatedUserOnPage:nextPage 
                         completionHandler:^(NSMutableArray *array, NSUInteger nextPage, NSError *error) {
                             if (error) {
                                 completionHandler(nil, error);
                             } else {
                                 // enumerate and check if any event matches lastEventDateString
                                 for (GHAPIEventV3 *event in array) {
                                     NSDate *eventDate = event.createdAtString.dateFromGithubAPIDateString;
                                     NSTimeInterval eventTimeInterval = eventDate.timeIntervalSince1970;
                                     
                                     if (eventTimeInterval == lastEventTimeIterval) {
                                         // this event matches the requested lastEventDateString
                                         completionHandler(eventsArray, nil);
                                         return;
                                     } else if (eventTimeInterval < lastEventTimeIterval) {
                                         // this event is older that the last known Event => abort
                                         completionHandler(eventsArray, nil);
                                         return;
                                     } else {
                                         [eventsArray addObject:event];
                                     }
                                 }
                                 
                                 // did not found last event in this array, dump next
                                 [self _dumpEventsForAuthenticatedUserSinceLastEventDateString:lastEventDateString
                                                                                nextPageToDump:nextPage
                                                                                       inArray:eventsArray
                                                                             completionHandler:completionHandler];
                             }
                         }];
}

+ (void)eventsForAuthenticatedUserSinceLastEventDateString:(NSString *)lastEventDateString 
                                         completionHandler:(void(^)(NSArray *events, NSError *error))completionHandler
{
    if (!lastEventDateString) {
        [self eventsForAuthenticatedUserOnPage:1 
                             completionHandler:^(NSMutableArray *array, NSUInteger nextPage, NSError *error) {
                                 if (error) {
                                     completionHandler(nil, error);
                                 } else {
                                     completionHandler(array, nil);
                                 }
                             }];
    } else {
        [self _dumpEventsForAuthenticatedUserSinceLastEventDateString:lastEventDateString
                                                       nextPageToDump:1
                                                              inArray:[NSMutableArray array] 
                                                    completionHandler:^(NSArray *events, NSError *error) {
                                                        completionHandler(events, error);
                                                    }];
    }
}

+ (void)eventsForAuthenticatedUserOnPage:(NSUInteger)page 
                       completionHandler:(GHAPIPaginationHandler)completionHandler
{
    NSString *username = [GHAPIAuthenticationManager sharedInstance].authenticatedUser.login;
    
    [self eventsForUserNamed:username
                        page:page
           completionHandler:completionHandler];
}

+ (void)eventsForUserNamed:(NSString *)username 
                      page:(NSUInteger)page 
         completionHandler:(GHAPIPaginationHandler)completionHandler
{
    //v3: GET /users/:user/received_events
    
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.github.com/users/%@/received_events",
                                       [username stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ] ];
    
    [[GHAPIBackgroundQueueV3 sharedInstance] sendRequestToURL:URL 
                                                         page:page 
                                                 setupHandler:nil 
                                  completionPaginationHandler:^(id object, NSError *error, ASIFormDataRequest *request, NSUInteger nextPage) {
                                      if (error) {
                                          completionHandler(nil, GHAPIPaginationNextPageNotFound, error);
                                      } else {
                                          NSArray *rawArray = GHAPIObjectExpectedClass(&object, NSArray.class);
                                          NSMutableArray *finalArray = [NSMutableArray arrayWithCapacity:rawArray.count];
                                          
                                          [rawArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                                              GHAPIEventV3 *event = [GHAPIEventV3 eventWithRawDictionary:obj];
                                              if (event) {
                                                  [finalArray addObject:event];
                                              }
                                          }];
                                          
                                          completionHandler(finalArray, nextPage, nil);
                                      }
                                  }];
}

+ (void)eventsByUserNamed:(NSString *)username 
                     page:(NSUInteger)page 
        completionHandler:(GHAPIPaginationHandler)completionHandler
{
    // v3: GET /users/:user/events
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.github.com/users/%@/events",
                                       [username stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ] ];
    
    [[GHAPIBackgroundQueueV3 sharedInstance] sendRequestToURL:URL 
                                                         page:page 
                                                 setupHandler:nil 
                                  completionPaginationHandler:^(id object, NSError *error, ASIFormDataRequest *request, NSUInteger nextPage) {
                                      if (error) {
                                          completionHandler(nil, GHAPIPaginationNextPageNotFound, error);
                                      } else {
                                          NSArray *rawArray = GHAPIObjectExpectedClass(&object, NSArray.class);
                                          NSMutableArray *finalArray = [NSMutableArray arrayWithCapacity:rawArray.count];
                                          
                                          [rawArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                                              GHAPIEventV3 *event = [GHAPIEventV3 eventWithRawDictionary:obj];
                                              if (event) {
                                                  [finalArray addObject:event];
                                              }
                                          }];
                                          
                                          completionHandler(finalArray, nextPage, nil);
                                      }
                                  }];
}

+ (void)eventsByAuthenticatedUserOnPage:(NSUInteger)page 
                      completionHandler:(GHAPIPaginationHandler)completionHandler
{
    NSString *username = [GHAPIAuthenticationManager sharedInstance].authenticatedUser.login;
    
    [self eventsByUserNamed:username
                       page:page
          completionHandler:completionHandler];
}

+ (void)eventsForOrganizationNamed:(NSString *)organizationName 
                              page:(NSUInteger)page 
                 completionHandler:(GHAPIPaginationHandler)completionHandler
{
    // v3: GET /users/:user/events/orgs/:org
    
    NSString *username = [GHAPIAuthenticationManager sharedInstance].authenticatedUser.login;
    
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.github.com/users/%@/events/orgs/%@",
                                       [username stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], 
                                       [organizationName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ]];
    
    [[GHAPIBackgroundQueueV3 sharedInstance] sendRequestToURL:URL 
                                                         page:page 
                                                 setupHandler:nil 
                                  completionPaginationHandler:^(id object, NSError *error, ASIFormDataRequest *request, NSUInteger nextPage) {
                                      if (error) {
                                          completionHandler(nil, GHAPIPaginationNextPageNotFound, error);
                                      } else {
                                          NSArray *rawArray = GHAPIObjectExpectedClass(&object, NSArray.class);
                                          NSMutableArray *finalArray = [NSMutableArray arrayWithCapacity:rawArray.count];
                                          
                                          [rawArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                                              GHAPIEventV3 *event = [GHAPIEventV3 eventWithRawDictionary:obj];
                                              if (event) {
                                                  [finalArray addObject:event];
                                              }
                                          }];
                                          
                                          completionHandler(finalArray, nextPage, nil);
                                      }
                                  }];
}

@end
