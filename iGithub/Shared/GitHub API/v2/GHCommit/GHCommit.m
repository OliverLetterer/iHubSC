//
//  GHCommit.m
//  iGithub
//
//  Created by Oliver Letterer on 15.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHCommit.h"


@implementation GHCommit

@synthesize message=_message, URL=_URL, ID=_ID, commitDate=_commitDate, authoredDate=_authoredDate, tree=_tree, added=_added, removed=_removed, parents=_parents, modified=_modified, author=_author, commiter=_commiter, user=_user;

#pragma mark - Initialization

- (id)initWithRawDictionary:(NSDictionary *)rawDictionary {
    rawDictionary = GHAPIObjectExpectedClass(rawDictionary, NSDictionary.class);
    if ((self = [super init])) {
        // Initialization code
        self.author = [[GHUser alloc] initWithRawDictionary:[rawDictionary objectForKey:@"author"] ];
        self.authoredDate = [rawDictionary objectForKeyOrNilOnNullObject:@"authored_date"];
        self.commitDate = [rawDictionary objectForKeyOrNilOnNullObject:@"committed_date"];
        self.commiter = [[GHUser alloc] initWithRawDictionary:[rawDictionary objectForKey:@"committer"] ];
        self.ID = [rawDictionary objectForKeyOrNilOnNullObject:@"id"];
        self.message = [rawDictionary objectForKeyOrNilOnNullObject:@"message"];
        self.tree = [rawDictionary objectForKeyOrNilOnNullObject:@"tree"];
        self.URL = [rawDictionary objectForKeyOrNilOnNullObject:@"url"];
        self.user = [[GHUser alloc] initWithRawDictionary:[rawDictionary objectForKeyOrNilOnNullObject:@"user"] ];
        
        self.modified = [NSMutableArray array];
        for (NSDictionary *fileInfo in [rawDictionary objectForKeyOrNilOnNullObject:@"modified"]) {
            [self.modified addObject:[[GHCommitFileInformation alloc] initWithRawDictionary:fileInfo] ];
        }
        
        self.removed = [NSMutableArray array];
        for (NSString *fileInfo in [rawDictionary objectForKeyOrNilOnNullObject:@"removed"]) {
            [self.removed addObject:fileInfo ];
        }
        
        self.added = [NSMutableArray array];
        for (NSString *fileInfo in [rawDictionary objectForKeyOrNilOnNullObject:@"added"]) {
            [self.added addObject:fileInfo ];
        }
        
        // Not impemented
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

#pragma mark - Keyed Archiving

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:_message forKey:@"message"];
    [encoder encodeObject:_added forKey:@"added"];
    [encoder encodeObject:_removed forKey:@"removed"];
    [encoder encodeObject:_parents forKey:@"parents"];
    [encoder encodeObject:_modified forKey:@"modified"];
    [encoder encodeObject:_author forKey:@"author"];
    [encoder encodeObject:_URL forKey:@"uRL"];
    [encoder encodeObject:_ID forKey:@"iD"];
    [encoder encodeObject:_commitDate forKey:@"commitDate"];
    [encoder encodeObject:_authoredDate forKey:@"authoredDate"];
    [encoder encodeObject:_tree forKey:@"tree"];
    [encoder encodeObject:_commiter forKey:@"commiter"];
    [encoder encodeObject:_user forKey:@"user"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super init])) {
        _message = [decoder decodeObjectForKey:@"message"];
        _added = [decoder decodeObjectForKey:@"added"];
        _removed = [decoder decodeObjectForKey:@"removed"];
        _parents = [decoder decodeObjectForKey:@"parents"];
        _modified = [decoder decodeObjectForKey:@"modified"];
        _author = [decoder decodeObjectForKey:@"author"];
        _URL = [decoder decodeObjectForKey:@"uRL"];
        _ID = [decoder decodeObjectForKey:@"iD"];
        _commitDate = [decoder decodeObjectForKey:@"commitDate"];
        _authoredDate = [decoder decodeObjectForKey:@"authoredDate"];
        _tree = [decoder decodeObjectForKey:@"tree"];
        _commiter = [decoder decodeObjectForKey:@"commiter"];
        _user = [decoder decodeObjectForKey:@"user"];
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
                handler([[GHCommit alloc] initWithRawDictionary:rawCommitDictionary], nil);
            }
        });
    });
    
}

#pragma mark - Memory management


@end
