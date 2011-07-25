//
//  ASIHTTPRequest+GithubAPIAdditions.m
//  iGithub
//
//  Created by Oliver Letterer on 06.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "ASIHTTPRequest+GithubAPIAdditions.h"
#import "GithubAPI.h"

@implementation ASIHTTPRequest (GHAPIRequestAdditions)

+ (ASIHTTPRequest *)authenticatedRequestWithURL:(NSURL *)URL {
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:URL];
    
    [request addBasicAuthenticationHeaderWithUsername:[GHAPIAuthenticationManager sharedInstance].username 
                                          andPassword:[GHAPIAuthenticationManager sharedInstance].password];
    
    return request;
}

+ (ASIFormDataRequest *)authenticatedFormDataRequestWithURL:(NSURL *)URL {
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:URL];
    
    if ([GHAPIAuthenticationManager sharedInstance].username && [GHAPIAuthenticationManager sharedInstance].password) {
        [request addBasicAuthenticationHeaderWithUsername:[GHAPIAuthenticationManager sharedInstance].username 
                                              andPassword:[GHAPIAuthenticationManager sharedInstance].password];
    }
    
    return request;
}

@end
