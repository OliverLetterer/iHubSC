//
//  GHAPIDownloadEventEventV3.m
//  iGithub
//
//  Created by Oliver Letterer on 02.11.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GithubAPI.h"



@implementation GHAPIDownloadEventV3
@synthesize download=_download;

#pragma mark - Initialization

- (id)initWithRawPayloadDictionary:(NSDictionary *)rawDictionary 
{
    GHAPIObjectExpectedClass(&rawDictionary, NSDictionary.class);
    if (self = [super initWithRawPayloadDictionary:rawDictionary]) {
        // Initialization code
        _download = [[GHAPIDownloadV3 alloc] initWithRawDictionary:[rawDictionary objectForKeyOrNilOnNullObject:@"download"] ];
    }
    return self;
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)encoder 
{
    [super encodeWithCoder:encoder];
    [encoder encodeObject:_download forKey:@"download"];
}

- (id)initWithCoder:(NSCoder *)decoder 
{
    if ((self = [super initWithCoder:decoder])) {
        _download = [decoder decodeObjectForKey:@"download"];
    }
    return self;
}

@end
