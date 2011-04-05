//
//  NSString+GithubAPIAdditions.m
//  iGithub
//
//  Created by Oliver Letterer on 05.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "NSString+GithubAPIAdditions.h"


@implementation NSString (GHAPIDateFormatting)

- (NSDate *)dateFromGithubAPIDateString {
    NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
    [formatter setDateFormat:@"yyyy/MM/dd HH:mm:ss ZZZ"];
    NSDate *date = [formatter dateFromString:self];
    
    return date;
}

@end
