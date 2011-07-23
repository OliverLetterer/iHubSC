//
//  GHUser.m
//  iGithub
//
//  Created by Oliver Letterer on 29.03.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHUser.h"
#import "GithubAPI.h"
#import "ASIHTTPRequest.h"

@implementation GHUser

@synthesize createdAt=_createdAt, gravatarID=_gravatarID, login=_login, type=_type, image=_image;
@synthesize followersCount=_followersCount, followingCount=_followingCount, ID=_ID, publicGistCount=_publicGistCount, publicRepoCount=_publicRepoCount;

@synthesize privateRepoCount=_privateRepoCount, collaborators=_collaborators, diskUsage=_diskUsage, ownedPrivateRepoCount=_ownedPrivateRepoCount, privateGistCount=_privateGistCount, planCollaborators=_planCollaborators, planSpace=_planSpace, planPrivateRepos=_planPrivateRepos;

@synthesize EMail=_EMail, location=_location, company=_company, blog=_blog;

@synthesize planName=_planName, password=_password;

- (BOOL)isAuthenticated {
    return self.password != nil && self.planName != nil;
}

#pragma mark - Initialization

+ (GHUser *)userFromRawUserDictionary:(NSDictionary *)rawDictionary {
    return [[[GHUser alloc] initWithRawUserDictionary:rawDictionary] autorelease];
}

#pragma mark - Keyed Archiving

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:_createdAt forKey:@"createdAt"];
    [encoder encodeInteger:_followersCount forKey:@"followersCount"];
    [encoder encodeInteger:_followingCount forKey:@"followingCount"];
    [encoder encodeObject:_gravatarID forKey:@"gravatarID"];
    [encoder encodeInteger:_ID forKey:@"iD"];
    [encoder encodeObject:_login forKey:@"login"];
    [encoder encodeInteger:_publicGistCount forKey:@"publicGistCount"];
    [encoder encodeInteger:_publicRepoCount forKey:@"publicRepoCount"];
    [encoder encodeObject:_type forKey:@"type"];
    [encoder encodeInteger:_privateRepoCount forKey:@"privateRepoCount"];
    [encoder encodeInteger:_collaborators forKey:@"collaborators"];
    [encoder encodeInteger:_diskUsage forKey:@"diskUsage"];
    [encoder encodeInteger:_ownedPrivateRepoCount forKey:@"ownedPrivateRepoCount"];
    [encoder encodeInteger:_privateGistCount forKey:@"privateGistCount"];
    [encoder encodeObject:_planName forKey:@"planName"];
    [encoder encodeInteger:_planCollaborators forKey:@"planCollaborators"];
    [encoder encodeInteger:_planSpace forKey:@"planSpace"];
    [encoder encodeInteger:_planPrivateRepos forKey:@"planPrivateRepos"];
    [encoder encodeObject:_password forKey:@"password"];
    [encoder encodeObject:_EMail forKey:@"eMail"];
    [encoder encodeObject:_location forKey:@"location"];
    [encoder encodeObject:_company forKey:@"company"];
    [encoder encodeObject:_blog forKey:@"blog"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super init])) {
        _createdAt = [[decoder decodeObjectForKey:@"createdAt"] retain];
        _followersCount = [decoder decodeIntegerForKey:@"followersCount"];
        _followingCount = [decoder decodeIntegerForKey:@"followingCount"];
        _gravatarID = [[decoder decodeObjectForKey:@"gravatarID"] retain];
        _ID = [decoder decodeIntegerForKey:@"iD"];
        _login = [[decoder decodeObjectForKey:@"login"] retain];
        _publicGistCount = [decoder decodeIntegerForKey:@"publicGistCount"];
        _publicRepoCount = [decoder decodeIntegerForKey:@"publicRepoCount"];
        _type = [[decoder decodeObjectForKey:@"type"] retain];
        _privateRepoCount = [decoder decodeIntegerForKey:@"privateRepoCount"];
        _collaborators = [decoder decodeIntegerForKey:@"collaborators"];
        _diskUsage = [decoder decodeIntegerForKey:@"diskUsage"];
        _ownedPrivateRepoCount = [decoder decodeIntegerForKey:@"ownedPrivateRepoCount"];
        _privateGistCount = [decoder decodeIntegerForKey:@"privateGistCount"];
        _planName = [[decoder decodeObjectForKey:@"planName"] retain];
        _planCollaborators = [decoder decodeIntegerForKey:@"planCollaborators"];
        _planSpace = [decoder decodeIntegerForKey:@"planSpace"];
        _planPrivateRepos = [decoder decodeIntegerForKey:@"planPrivateRepos"];
        _password = [[decoder decodeObjectForKey:@"password"] retain];
        _EMail = [[decoder decodeObjectForKey:@"eMail"] retain];
        _location = [[decoder decodeObjectForKey:@"location"] retain];
        _company = [[decoder decodeObjectForKey:@"company"] retain];
        _blog = [[decoder decodeObjectForKey:@"blog"] retain];
    }
    return self;
}

+ (void)searchUsersWithSearchString:(NSString *)searchString completionHandler:(void (^)(NSArray *, NSError *))handler {
    dispatch_async(GHAPIBackgroundQueue(), ^(void) {
        
        // http://github.com/api/v2/xml/user/search/chacon
        
        NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://github.com/api/v2/json/user/search/%@",
                                           [searchString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ] ];
        
        NSError *myError = nil;
        
        ASIFormDataRequest *request = [ASIFormDataRequest authenticatedFormDataRequestWithURL:URL];
        [request startSynchronous];
        
        myError = [request error];
        
        if (!myError) {
            myError = [NSError errorFromRawDictionary:[[request responseString] objectFromJSONString] ];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            if (myError) {
                handler(nil, myError);
            } else {
                NSDictionary *dictionary = [[request responseString] objectFromJSONString];
                
                NSArray *allUsers = [dictionary objectForKeyOrNilOnNullObject:@"users"];
                NSMutableArray *users = [NSMutableArray arrayWithCapacity:[allUsers count] ];
                
                for (NSDictionary *rawUser in allUsers) {
                    [users addObject:[[[GHUser alloc] initWithRawDictionary:rawUser] autorelease] ];
                }
                
                handler(users, nil);
            }
        });
    });
}

- (id)initWithRawUserDictionary:(NSDictionary *)rawDictionary {
    NSDictionary *userDictionary = [rawDictionary objectForKeyOrNilOnNullObject:@"user"];
    if ((self = [self initWithRawDictionary:userDictionary])) {
        // setup here
    }
    return self;
}

- (id)initWithRawDictionary:(NSDictionary *)rawDictionary {
    if ((self = [super init])) {
        // setup here
        self.createdAt = [rawDictionary objectForKeyOrNilOnNullObject:@"created_at"];
        self.gravatarID = [rawDictionary objectForKeyOrNilOnNullObject:@"gravatar_id"];
        self.login = [rawDictionary objectForKeyOrNilOnNullObject:@"login"];
        self.type = [rawDictionary objectForKeyOrNilOnNullObject:@"type"];
        
        self.followersCount = [[rawDictionary objectForKeyOrNilOnNullObject:@"followers_count"] intValue];
        self.followingCount = [[rawDictionary objectForKeyOrNilOnNullObject:@"following_count"] intValue];
        self.ID = [[rawDictionary objectForKeyOrNilOnNullObject:@"id"] intValue];
        self.publicGistCount = [[rawDictionary objectForKeyOrNilOnNullObject:@"public_gist_count"] intValue];
        self.publicRepoCount = [[rawDictionary objectForKeyOrNilOnNullObject:@"public_repo_count"] intValue];
        
        // private github stuff
        self.privateRepoCount = [[rawDictionary objectForKeyOrNilOnNullObject:@"total_private_repo_count"] intValue];
        self.collaborators = [[rawDictionary objectForKeyOrNilOnNullObject:@"collaborators"] intValue];
        self.diskUsage = [[rawDictionary objectForKeyOrNilOnNullObject:@"disk_usage"] intValue];
        self.ownedPrivateRepoCount = [[rawDictionary objectForKeyOrNilOnNullObject:@"owned_private_repo_count"] intValue];
        self.privateGistCount = [[rawDictionary objectForKeyOrNilOnNullObject:@"private_gist_count"] intValue];
        
        self.planName = [[rawDictionary objectForKeyOrNilOnNullObject:@"plan"] objectForKeyOrNilOnNullObject:@"name"];
        self.planCollaborators = [[[rawDictionary objectForKeyOrNilOnNullObject:@"plan"] objectForKeyOrNilOnNullObject:@"collaborators"] intValue];
        self.planSpace = [[[rawDictionary objectForKeyOrNilOnNullObject:@"plan"] objectForKeyOrNilOnNullObject:@"space"] intValue];
        self.planPrivateRepos = [[[rawDictionary objectForKeyOrNilOnNullObject:@"plan"] objectForKeyOrNilOnNullObject:@"private_repos"] intValue];
        
        self.EMail = [rawDictionary objectForKeyOrNilOnNullObject:@"email"];
        self.location = [rawDictionary objectForKeyOrNilOnNullObject:@"location"];
        self.company = [rawDictionary objectForKeyOrNilOnNullObject:@"company"];
        self.blog = [rawDictionary objectForKeyOrNilOnNullObject:@"blog"];
        
        // API v3
        if (!self.gravatarID) {
            NSString *gravatarURL = [rawDictionary objectForKeyOrNilOnNullObject:@"avatar_url"];
            self.gravatarID = gravatarURL.gravarID;
        }
    }
    return self;
}

#pragma mark - Memory management

- (void)dealloc {
    [_createdAt release];
    [_gravatarID release];
    [_login release];
    [_type release];
    [_image release];
    [_planName release];
    [_password release];
    
    [_location release];
    [_EMail release];
    [_company release];
    [_blog release];
    
    [_image release];
    [super dealloc];
}

@end
