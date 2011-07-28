//
//  GHIssue.m
//  iGithub
//
//  Created by Oliver Letterer on 01.04.11.
//  Copyright (c) 2011 Home. All rights reserved.
//

#import "GHIssue.h"
#import "GithubAPI.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"

@implementation GHIssue

@dynamic gravatarID;
@dynamic position;
@dynamic number;
@dynamic votes;
@dynamic creationDate;
@dynamic comments;
@dynamic body;
@dynamic title;
@dynamic updatedAd;
@dynamic closedAd;
@dynamic user;
@dynamic labelsJSON;
@dynamic state;
@dynamic lastUpdateDate;

@synthesize repository;

- (void)updateWithRawDictionary:(NSDictionary *)rawDictionary onRepository:(NSString *)theRepository {
    rawDictionary = GHAPIObjectExpectedClass(rawDictionary, NSDictionary.class);
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
    
    self.lastUpdateDate = [NSDate date];
    self.repository = theRepository;
}

+ (GHIssue *)issueFromDatabaseOnRepository:(NSString *)repository 
                                withNumber:(NSNumber *)number {
    
    if (repository == nil || number == nil) {
        return nil;
    }
    
    NSManagedObjectContext *moc = GHSharedManagedObjectContext();
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"GHIssue" inManagedObjectContext:moc];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    
    // Set example predicate and sort orderings...
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(number == %@) AND (repository like %@)", number, repository];
    [request setPredicate:predicate];
    
    
    NSError *error = nil;
    NSArray *array = [moc executeFetchRequest:request error:&error];
    if (array == nil)
    {
        // Deal with error...
    }
    
    if ([array count] > 0) {
        GHIssue *issue = [array objectAtIndex:0];
        if (fabs([issue.lastUpdateDate timeIntervalSinceNow] > 172800)) {
            // issue is not up to date, delete it
            [moc deleteObject:issue];
            [moc save:NULL];
            return nil;
        }
        return [array objectAtIndex:0];
    }
    
    return nil;
}

+ (void)deleteCachedIssueInDatabaseOnRepository:(NSString *)repository withNumber:(NSNumber *)number {
    if (repository == nil || number == nil) {
        return;
    }
    
    NSManagedObjectContext *moc = GHSharedManagedObjectContext();
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"GHIssue" inManagedObjectContext:moc];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    
    // Set example predicate and sort orderings...
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(number == %@) AND (repository like %@)", number, repository];
    [request setPredicate:predicate];
    
    
    NSError *error = nil;
    NSArray *array = [moc executeFetchRequest:request error:&error];
    for (GHIssue *issue in array) {
        [moc deleteObject:issue];
        [moc save:NULL];
    }
}

+ (BOOL)isIssueAvailableForRepository:(NSString *)repository 
                           withNumber:(NSNumber *)number {
    return [self issueFromDatabaseOnRepository:repository withNumber:number] != nil;
}

+ (void)issueOnRepository:(NSString *)repository 
               withNumber:(NSNumber *)number 
    useDatabaseIfPossible:(BOOL)useDatabase
        completionHandler:(void (^)(GHIssue *issue, NSError *error, BOOL didDownload))handler {
    
    // use URL http://github.com/api/v2/json/issues/show/schacon/showoff/1
    
    if (useDatabase) {
        GHIssue *cachedIssue = [GHIssue issueFromDatabaseOnRepository:repository withNumber:number];
        if (cachedIssue) {
            handler(cachedIssue, nil, NO);
            return;
        }
    }
    
    dispatch_async(GHAPIBackgroundQueue(), ^(void) {
        
        NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://github.com/api/v2/json/issues/show/%@/%@",
                                           [repository stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                                           number]];
        
        NSError *myError = nil;
        
        ASIHTTPRequest *request = [ASIHTTPRequest authenticatedFormDataRequestWithURL:URL];
        [request startSynchronous];
        
        myError = [request error];
        
        NSData *issueData = [request responseData];
        NSString *issueString = [[NSString alloc] initWithData:issueData encoding:NSUTF8StringEncoding];
        
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            if (myError) {
                handler(nil, myError, NO);
            } else {
                NSDictionary *issueDictionary = [issueString objectFromJSONString];
                NSManagedObjectContext *ctx = GHSharedManagedObjectContext();
                [self deleteCachedIssueInDatabaseOnRepository:repository withNumber:number];
                GHIssue *newIssue = (GHIssue *)[NSEntityDescription insertNewObjectForEntityForName:@"GHIssue" 
                                                                             inManagedObjectContext:ctx];
                NSDictionary *rawDictionary = [issueDictionary objectForKey:@"issue"];
                [newIssue updateWithRawDictionary:rawDictionary onRepository:repository];
                
                [ctx save:NULL];
                handler(newIssue, nil, YES);
            }
        });
    });
}


+ (void)postComment:(NSString *)comment forIssueOnRepository:(NSString *)repository 
         withNumber:(NSNumber *)number 
  completionHandler:(void (^)(GHIssueComment *, NSError *))handler {
    
    dispatch_async(GHAPIBackgroundQueue(), ^(void) {
        
        // https://github.com/api/v2/json/issues/comment/defunkt/dunder-mifflin/1
        
        NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://github.com/api/v2/json/issues/comment/%@/%@",
                                           [repository stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                                           number]];
        
        NSError *myError = nil;
        
        ASIFormDataRequest *request = [ASIFormDataRequest authenticatedFormDataRequestWithURL:URL];
        [request setPostValue:comment forKey:@"comment"];
        [request startSynchronous];
        
        myError = [request error];
        
        NSData *issueData = [request responseData];
        NSString *issueString = [[NSString alloc] initWithData:issueData encoding:NSUTF8StringEncoding];
        
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            if (myError) {
                handler(nil, myError);
            } else {
                NSDictionary *responseDictionary = [issueString objectFromJSONString];
                NSDictionary *rawDictionary = [responseDictionary objectForKey:@"comment"];
                
                GHIssueComment *comment = [[GHIssueComment alloc] initWithRawDictionary:rawDictionary];
                
                handler(comment, nil);
            }
        });
    });
}

@end
