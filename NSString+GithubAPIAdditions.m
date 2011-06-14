//
//  NSString+GithubAPIAdditions.m
//  iGithub
//
//  Created by Oliver Letterer on 05.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "NSString+GithubAPIAdditions.h"
#import "NSDate+GithubAPIAdditions.h"
#import "UIColor+GithubAPI.h"
#import "GithubAPI.h"
#import "WAHTMLMarkdownFormatter.h"

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
    __block NSUInteger nextPage = GHAPIPaginationNextPageNotFound;
    
    NSArray *basicLinksArray = [self componentsSeparatedByString:@","];
    
    for (NSString *basicLinkString in basicLinksArray) {
        if ([basicLinkString rangeOfString:@"rel=\"next\""].location != NSNotFound) {
            
            NSRegularExpression *expression = [[[NSRegularExpression alloc] initWithPattern:@"page=(0|1|2|3|4|5|6|7|8|9)+" options:NSRegularExpressionCaseInsensitive error:NULL] autorelease];
            
            
            
            [expression enumerateMatchesInString:basicLinkString options:0 range:NSMakeRange(0, basicLinkString.length) 
                                      usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                                          NSRange range = NSMakeRange(result.range.location+5, result.range.length-5);
                                          NSString *pageNumberString = [self substringWithRange:range];
                                          nextPage = [pageNumberString integerValue];
                                      }];
        }
    }
    
    return nextPage;
}

@end



@implementation NSString (GHAPIColorParsing)

- (UIColor *)colorFromAPIColorString {
    return [UIColor colorFromAPIHexColorString:self];
}

@end



@implementation NSString (Parsing)

- (NSString *)substringBetweenLeftBounds:(NSString *)leftBounds andRightBounds:(NSString *)rightBounds {
	NSString *result = nil;
	
	@try {
		NSRange beforeRange = NSMakeRange(0, 0);
		beforeRange = [self rangeOfString:leftBounds];
		if (beforeRange.location != NSNotFound) {
			// found before
			NSRange rightAfterRange = NSMakeRange(0, 0);
			NSRange searchRange = NSMakeRange(beforeRange.length + beforeRange.location, [self length] - beforeRange.length - beforeRange.location);
			rightAfterRange = [self rangeOfString:rightBounds options:NSLiteralSearch range:searchRange];
			if (rightAfterRange.location != NSNotFound) {
				NSRange foundRange = NSMakeRange(beforeRange.length + beforeRange.location, rightAfterRange.location - (beforeRange.length + beforeRange.location));
				result = [self substringWithRange:foundRange];
			}
		}
	}
	@catch (NSException *e) {}
	
	return result;
}

@end




NSString *const kGHNSStringMarkdownStyleFull = @"MarkdownStyle";


@implementation NSString (GHMarkdownParsing)
- (NSString *)HTMLMarkdownFormattedString {
    return [self stringFromMarkdownStyle:kGHNSStringMarkdownStyleFull];
}

- (NSString *)stringFromMarkdownStyle:(NSString *)markdownStyle {
    NSString *formatFilePath = [[NSBundle mainBundle] pathForResource:markdownStyle ofType:nil];
    NSString *style = [NSString stringWithContentsOfFile:formatFilePath 
                                                encoding:NSUTF8StringEncoding 
                                                   error:NULL];
    NSMutableString *parsedString = [NSMutableString stringWithFormat:@"%@", style];
    
    WAHTMLMarkdownFormatter *formatter = [[[WAHTMLMarkdownFormatter alloc] init] autorelease];
    [parsedString appendFormat:@"%@", [formatter HTMLForMarkdown:self]];
    return parsedString;
}

@end