//
//  GHCommit.m
//  iGithub
//
//  Created by Oliver Letterer on 15.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHCommit.h"


@implementation GHCommit

@synthesize message=_message, URL=_URL, ID=_ID, commitDate=_commitDate, authoredDate=_authoredDate, tree=_tree, added=_added, removed=_removed, parents=_parents, modified=_modified, author=_author, commiter=_commiter;

#pragma mark - Initialization

- (id)initWithRawDictionary:(NSDictionary *)rawDictionary {
    if ((self = [super init])) {
        // Initialization code
        self.author = [[[GHUser alloc] initWithRawDictionary:[rawDictionary objectForKey:@"author"] ] autorelease];
        self.authoredDate = [rawDictionary objectForKeyOrNilOnNullObject:@"authored_date"];
        self.commitDate = [rawDictionary objectForKeyOrNilOnNullObject:@"committed_date"];
        self.commiter = [[[GHUser alloc] initWithRawDictionary:[rawDictionary objectForKey:@"committer"] ] autorelease];
        self.ID = [rawDictionary objectForKeyOrNilOnNullObject:@"id"];
        self.message = [rawDictionary objectForKeyOrNilOnNullObject:@"message"];
        self.tree = [rawDictionary objectForKeyOrNilOnNullObject:@"tree"];
        self.URL = [rawDictionary objectForKeyOrNilOnNullObject:@"url"];
        
        self.modified = [NSMutableArray array];
        for (NSDictionary *fileInfo in [rawDictionary objectForKeyOrNilOnNullObject:@"modified"]) {
            [self.modified addObject:[[[GHCommitFileInformation alloc] initWithRawDictionary:fileInfo] autorelease] ];
        }
        
        self.removed = [NSMutableArray array];
        for (NSString *fileInfo in [rawDictionary objectForKeyOrNilOnNullObject:@"removed"]) {
            [self.removed addObject:fileInfo ];
        }
        
        self.added = [NSMutableArray array];
        for (NSString *fileInfo in [rawDictionary objectForKeyOrNilOnNullObject:@"added"]) {
            [self.added addObject:fileInfo ];
        }
        
#warning parents is not implemented yet
        /*
         parents looks like this in rawDictionary
         
         parents =         (
         {
         id = 30a7ca972ab92396156dcc0c9e293bf5b04db118;
         },
         {
         id = ce1db2e799b6c62cb6fe9d24602468be2cc175a0;
         }
         );
         */
    }
    return self;
}

+ (void)commit:(NSString *)commitID onRepository:(NSString *)repository 
                               completionHandler:(void(^)(GHCommit *commit, NSError *error))handler {
    
    dispatch_async(GHAPIBackgroundQueue(), ^(void) {
        
        // commits/show/:user_id/:repository/:sha
        
        NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://github.com/api/v2/json/commits/show/%@/%@",
                                           [repository stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                                           [commitID stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ] ];
        
        NSError *myError = nil;
        
        ASIFormDataRequest *request = [ASIFormDataRequest authenticatedFormDataRequestWithURL:URL];
        [request startSynchronous];
        
        myError = [request error];
        
        if (!myError) {
            myError = [NSError errorFromRawDictionary:[[request responseString] objectFromJSONString] ];
        }
        
        NSString *jsonString = [request responseString];
        
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            if (myError) {
                handler(nil, myError);
            } else {
                NSDictionary *dictionary = [jsonString objectFromJSONString];
                NSDictionary *rawCommitDictionary = [dictionary objectForKey:@"commit"];
                DLog(@"%@", dictionary);
                handler([[[GHCommit alloc] initWithRawDictionary:rawCommitDictionary] autorelease], nil);
            }
        });
    });
    
}

#pragma mark - Memory management

- (void)dealloc {
    [_message release];
    [_URL release];
    [_ID release];
    [_commitDate release];
    [_authoredDate release];
    [_tree release];
    [_added release];
    [_removed release];
    [_parents release];
    [_modified release];
    [_author release];
    [_commiter release];
    
    [super dealloc];
}

@end
