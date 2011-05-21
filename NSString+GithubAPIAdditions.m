//
//  NSString+GithubAPIAdditions.m
//  iGithub
//
//  Created by Oliver Letterer on 05.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "NSString+GithubAPIAdditions.h"
#import "NSDate+GithubAPIAdditions.h"

@implementation NSString (GHAPIDateFormatting)

- (NSDate *)dateFromGithubAPIDateString {
    NSString *_tmpString = nil;
    NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
    [formatter setDateFormat:@"yyyy/MM/dd HH:mm:ss ZZZ"];
    NSDate *date = [formatter dateFromString:self];
    
    if (!date) {
        formatter = [[[NSDateFormatter alloc] init] autorelease];
        _tmpString = [self stringByReplacingOccurrencesOfString:@"-" withString:@"/"];
        _tmpString = [_tmpString stringByReplacingOccurrencesOfString:@"T" withString:@" "];
        _tmpString = [_tmpString stringByReplacingOccurrencesOfString:@"Z" withString:@" -0700"];
        [formatter setDateFormat:@"yyyy/MM/dd HH:mm:ss ZZZ"];
        date = [formatter dateFromString:_tmpString];
    }
    
    return date;
}

- (NSString *)gravarID {
    NSRange range = [self rangeOfString:@"/avatar/"];
    
    if (range.length > 0) {
        // found
        NSUInteger length = 32;
        NSUInteger location = range.location + range.length;
        if (location + length <= self.length) {
            NSString *found = [self substringWithRange:NSMakeRange(location, length)];
            return found;
        }
    }
    return nil;
}

- (NSString *)prettyTimeIntervalSinceNow {
    NSDate *date = self.dateFromGithubAPIDateString;
    return date.prettyTimeIntervalSinceNow;
}

@end



@implementation NSString (GHAPIHTTPParsing)

- (NSUInteger)nextPage {
    NSArray *basicLinksArray = [self componentsSeparatedByString:@","];
    
    for (NSString *basicLinkString in basicLinksArray) {
        if ([basicLinkString rangeOfString:@"rel=\"next\""].length > 0) {
            NSArray *furtherComponents = [basicLinkString componentsSeparatedByString:@"?page="];
            
            NSString *lastObject = [furtherComponents lastObject];
            
            NSArray *lastComponents = [lastObject componentsSeparatedByString:@">"];
            
            if (lastComponents.count > 0) {
                NSString *nextPageNumber = [lastComponents objectAtIndex:0];
                return [nextPageNumber intValue];
            }
        }
    }
    
    return 0;
}

@end

