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
    
    [request addBasicAuthenticationHeaderWithUsername:[GHAPIAuthenticationManager sharedInstance].authenticatedUser.login 
                                          andPassword:[GHAPIAuthenticationManager sharedInstance].authenticatedUser.password];
    
    return request;
}

+ (ASIFormDataRequest *)authenticatedFormDataRequestWithURL:(NSURL *)URL {
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:URL];
    
    if ([GHAPIAuthenticationManager sharedInstance].authenticatedUser) {
        [request addBasicAuthenticationHeaderWithUsername:[GHAPIAuthenticationManager sharedInstance].authenticatedUser.login 
                                              andPassword:[GHAPIAuthenticationManager sharedInstance].authenticatedUser.password];
    }
    
    return request;
}

@end
