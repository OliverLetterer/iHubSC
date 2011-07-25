//
//  GHFileMetaData.m
//  iGithub
//
//  Created by Oliver Letterer on 18.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHFileMetaData.h"
#import "GithubAPI.h"

@implementation GHFileMetaData

@synthesize name=_name, size=_size, hash=_hash, mode=_mode, mimeType=_mimeType, repository=_repository;

#pragma mark - Initialization

- (id)initWithRawDictionary:(NSDictionary *)rawDictionary {
    rawDictionary = GHAPIObjectExpectedClass(rawDictionary, NSDictionary.class);
    if ((self = [super init])) {
        // Initialization code
        self.name = [rawDictionary objectForKeyOrNilOnNullObject:@"name"];
        self.size = [rawDictionary objectForKeyOrNilOnNullObject:@"size"];
        self.hash = [rawDictionary objectForKeyOrNilOnNullObject:@"sha"];
        self.mode = [rawDictionary objectForKeyOrNilOnNullObject:@"mode"];
        self.mimeType = [rawDictionary objectForKeyOrNilOnNullObject:@"mime_type"];
    }
    return self;
}

#pragma mark - Keyed Archiving

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:_name forKey:@"name"];
    [encoder encodeObject:_size forKey:@"size"];
    [encoder encodeObject:_hash forKey:@"hash"];
    [encoder encodeObject:_mode forKey:@"mode"];
    [encoder encodeObject:_mimeType forKey:@"mimeType"];
    [encoder encodeObject:_repository forKey:@"repository"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super init])) {
        _name = [[decoder decodeObjectForKey:@"name"] retain];
        _size = [[decoder decodeObjectForKey:@"size"] retain];
        _hash = [[decoder decodeObjectForKey:@"hash"] retain];
        _mode = [[decoder decodeObjectForKey:@"mode"] retain];
        _mimeType = [[decoder decodeObjectForKey:@"mimeType"] retain];
        _repository = [[decoder decodeObjectForKey:@"repository"] retain];
    }
    return self;
}

+ (void)metaDataOfFile:(NSString *)filename 
         atRelativeURL:(NSString *)relativeURL 
          onRepository:(NSString *)repository 
                  tree:(NSString *)tree 
     completionHandler:(void (^)(GHFileMetaData *, NSError *))handler {
    
    dispatch_async(GHAPIBackgroundQueue(), ^(void) {
        
        // http://github.com/api/v2/json/blob/show/defunkt/facebox/365b84e0fd92c47ecdada91da47f2d67500b8e31/README.txt
        
        NSURL *URL = [NSURL URLWithString:@"http://github.com/api/v2/json/blob/show/"];
        URL = [URL URLByAppendingPathComponent:[repository stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        URL = [URL URLByAppendingPathComponent:[tree stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        if (![relativeURL isEqualToString:@"/"]) {
            URL = [URL URLByAppendingPathComponent:relativeURL];
        }
        URL = [URL URLByAppendingPathComponent:filename];
        NSString *URLString = [URL absoluteString];
        URL = [NSURL URLWithString:[URLString stringByAppendingString:@"?meta=1"]];
        
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
                NSDictionary *dictionary = [[[request responseString] objectFromJSONString] objectForKeyOrNilOnNullObject:@"blob"];
                GHFileMetaData *meta = [[[GHFileMetaData alloc] initWithRawDictionary:dictionary] autorelease];
                meta.repository = repository;
                handler(meta, nil);
            }
        });
    });
}

- (void)contentOfFileWithCompletionHandler:(void (^)(NSData *, NSError *))handler {
    
    dispatch_async(GHAPIBackgroundQueue(), ^(void) {
        
        // http://github.com/api/v2/json/blob/show/dbloete/ioctocat/00286785236f11899a7d9f83e6923fb94bb81ce4
        
        NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"http://github.com/api/v2/json/blob/show/%@/%@", 
                                           self.repository, self.hash] ];
        
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
                handler([request responseData], nil);
            }
        });
    });
}

- (ASIHTTPRequest *)requestForContent {
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"http://github.com/api/v2/json/blob/show/%@/%@", 
                                       self.repository, self.hash] ];
    ASIFormDataRequest *request = [ASIFormDataRequest authenticatedFormDataRequestWithURL:URL];
    
    return request;
}

#pragma mark - Memory management

- (void)dealloc {
    [_name release];
    [_size release];
    [_hash release];
    [_mode release];
    [_mimeType release];
    [_repository release];
    
    [super dealloc];
}

@end
