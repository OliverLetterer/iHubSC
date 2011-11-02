//
//  GHAPIDownloadV3.m
//  iGithub
//
//  Created by Oliver Letterer on 02.11.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GithubAPI.h"



@implementation GHAPIDownloadV3
@synthesize URL = _URL, HTMLURL = _HTMLURL, ID = _ID, name = _name, description = _description, size = _size, downloadCount = _downloadCount, contentType = _contentType;

#pragma mark - Initialization

- (id)initWithRawDictionary:(NSDictionary *)rawDictionary
{
    GHAPIObjectExpectedClass(&rawDictionary, NSDictionary.class);
    if (self = [super init]) {
        // Initialization code
        _URL = [rawDictionary objectForKeyOrNilOnNullObject:@"url"];
        _HTMLURL = [rawDictionary objectForKeyOrNilOnNullObject:@"html_url"];
        _ID = [rawDictionary objectForKeyOrNilOnNullObject:@"id"];
        _name = [rawDictionary objectForKeyOrNilOnNullObject:@"name"];
        _description = [rawDictionary objectForKeyOrNilOnNullObject:@"description"];
        _size = [rawDictionary objectForKeyOrNilOnNullObject:@"size"];
        _downloadCount = [rawDictionary objectForKeyOrNilOnNullObject:@"download_count"];
        _contentType = [rawDictionary objectForKeyOrNilOnNullObject:@"content_type"];
    }
    return self;
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)encoder 
{
    [encoder encodeObject:_URL forKey:@"uRL"];
    [encoder encodeObject:_HTMLURL forKey:@"hTMLURL"];
    [encoder encodeObject:_ID forKey:@"iD"];
    [encoder encodeObject:_name forKey:@"name"];
    [encoder encodeObject:_description forKey:@"description"];
    [encoder encodeObject:_size forKey:@"size"];
    [encoder encodeObject:_downloadCount forKey:@"downloadCount"];
    [encoder encodeObject:_contentType forKey:@"contentType"];
}

- (id)initWithCoder:(NSCoder *)decoder 
{
    if ((self = [super init])) {
        _URL = [decoder decodeObjectForKey:@"uRL"];
        _HTMLURL = [decoder decodeObjectForKey:@"hTMLURL"];
        _ID = [decoder decodeObjectForKey:@"iD"];
        _name = [decoder decodeObjectForKey:@"name"];
        _description = [decoder decodeObjectForKey:@"description"];
        _size = [decoder decodeObjectForKey:@"size"];
        _downloadCount = [decoder decodeObjectForKey:@"downloadCount"];
        _contentType = [decoder decodeObjectForKey:@"contentType"];
    }
    return self;
}

@end
