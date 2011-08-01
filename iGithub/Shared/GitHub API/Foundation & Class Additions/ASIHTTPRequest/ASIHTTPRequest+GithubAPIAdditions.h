//
//  ASIHTTPRequest+GithubAPIAdditions.h
//  iGithub
//
//  Created by Oliver Letterer on 06.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"


@interface ASIHTTPRequest (GHAPIRequestAdditions)

+ (ASIHTTPRequest *)authenticatedRequestWithURL:(NSURL *)URL;
+ (ASIFormDataRequest *)authenticatedFormDataRequestWithURL:(NSURL *)URL;

@end
