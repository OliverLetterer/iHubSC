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
    self.gravatarID = [rawDictionary objectForKey:@"gravatar_id"];
    self.position = [rawDictionary objectForKey:@"position"];
    self.number = [rawDictionary objectForKey:@"number"];
    self.votes = [rawDictionary objectForKey:@"votes"];
    self.creationDate = [rawDictionary objectForKey:@"created_at"];
    self.comments = [rawDictionary objectForKey:@"comments"];
    self.body = [rawDictionary objectForKey:@"body"];
    self.title = [rawDictionary objectForKey:@"title"];
    self.updatedAd = [rawDictionary objectForKey:@"updated_at"];
    self.closedAd = [rawDictionary objectForKey:@"closed_at"];
    self.user = [rawDictionary objectForKey:@"user"];
    self.labelsJSON = [(NSArray *)[rawDictionary objectForKey:@"labels"] JSONString];
    self.state = [rawDictionary objectForKey:@"state"];
    
    self.lastUpdateDate = [NSDate date];
    self.repository = theRepository;
}

+ (GHIssue *)issueFromDatabaseOnRepository:(NSString *)repository 
                                withNumber:(NSNumber *)number {
    
    NSManagedObjectContext *moc = GHSharedManagedObjectContext();
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"GHIssue" inManagedObjectContext:moc];
    NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
    [request setEntity:entityDescription];
    
    // Set example predicate and sort orderings...
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(number == %@) AND (repository LIKE '%@')", number, repository];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(number == %@) AND (repository like %@)", number, repository];

    [request setPredicate:predicate];
    
//    NSSortDescriptor *sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"firstName" ascending:YES] autorelease];
//    [request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    NSError *error = nil;
    NSArray *array = [moc executeFetchRequest:request error:&error];
    if (array == nil)
    {
        // Deal with error...
    }
    
    if ([array count] > 0) {
        return [array objectAtIndex:0];
    }
    
    return nil;
}

+ (void)issueOnRepository:(NSString *)repository 
               withNumber:(NSNumber *)number 
            loginUsername:(NSString *)loginUsername 
                 password:(NSString *)password completionHandler:(void (^)(GHIssue *issue, NSError *error))handler {
    
    // use URL http://github.com/api/v2/json/issues/show/schacon/showoff/1
    
    GHIssue *cachedIssue = [GHIssue issueFromDatabaseOnRepository:repository withNumber:number];
    if (cachedIssue) {
        handler(cachedIssue, nil);
        return;
    }
    
    dispatch_async(GHAPIBackgroundQueue(), ^(void) {
        
        NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://github.com/api/v2/json/issues/show/%@/%@",
                                           [repository stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                                           number]];
        
        NSError *myError = nil;
        
        ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:URL];
        [request addRequestHeader:@"Authorization" 
                            value:[NSString stringWithFormat:@"Basic %@",[ASIHTTPRequest base64forData:[[NSString stringWithFormat:@"%@:%@",loginUsername,password] dataUsingEncoding:NSUTF8StringEncoding]]]];
        [request startSynchronous];
        
        myError = [request error];
        
        NSData *issueData = [request responseData];
        NSString *issueString = [[[NSString alloc] initWithData:issueData encoding:NSUTF8StringEncoding] autorelease];
        
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            if (myError) {
                handler(nil, myError);
            } else {
                NSDictionary *issueDictionary = [issueString objectFromJSONString];
                NSManagedObjectContext *ctx = GHSharedManagedObjectContext();
                GHIssue *newIssue = (GHIssue *)[NSEntityDescription insertNewObjectForEntityForName:@"GHIssue" 
                                                                             inManagedObjectContext:ctx];
                NSDictionary *rawDictionary = [issueDictionary objectForKey:@"issue"];
                [newIssue updateWithRawDictionary:rawDictionary onRepository:repository];
                
                [ctx save:NULL];
                handler(newIssue, nil);
            }
        });
    });
    
}

@end
