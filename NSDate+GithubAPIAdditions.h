//
//  NSDate+GithubAPIAdditions.h
//  iGithub
//
//  Created by Oliver Letterer on 05.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSDate (GHAPIDateFormatting)

@property (nonatomic, readonly) NSString *prettyTimeIntervalSinceNow;
@property (nonatomic, readonly) NSString *stringInGithubAPIFormat;

@end
