//
//  NSString+GithubAPIAdditions.h
//  iGithub
//
//  Created by Oliver Letterer on 05.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSString (GHAPIDateFormatting)

@property (nonatomic, readonly) NSDate *dateFromGithubAPIDateString;

@end