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
#import <CommonCrypto/CommonDigest.h> // Need to import for CC_MD5 access
#import "NSAttributedString+HTML.h"

@implementation NSString (GHAPIDateFormatting)

- (NSDate *)dateFromGithubAPIDateString {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy/MM/dd HH:mm:ss ZZZ"];
    NSDate *date = [formatter dateFromString:self];
    
    if (!date) {
        NSDateFormatter *f = [[NSDateFormatter alloc] init];
        [f setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
        f.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
        f.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        f.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        date = [f dateFromString:self];
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

- (NSString *)prettyShortTimeIntervalSinceNow {
    NSDate *date = self.dateFromGithubAPIDateString;
    return date.prettyShortTimeIntervalSinceNow;
}

@end





@implementation NSString (GHAPIHTTPParsing)

- (NSUInteger)nextPage {
    __block NSUInteger nextPage = GHAPIPaginationNextPageNotFound;
    
    NSArray *basicLinksArray = [self componentsSeparatedByString:@","];
    
    for (NSString *basicLinkString in basicLinksArray) {
        if ([basicLinkString rangeOfString:@"rel=\"next\""].location != NSNotFound) {
            
            NSRegularExpression *expression = [[NSRegularExpression alloc] initWithPattern:@"page=(0|1|2|3|4|5|6|7|8|9)+&" options:NSRegularExpressionCaseInsensitive error:NULL];
            
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





@implementation NSString (GHMarkdownParsing)

- (NSAttributedString *)selectedAttributesStringFromMarkdown {
    NSString *HTML = [GHAPIMarkdownFormatter selectedFormattedHTMLStringFromMarkdownString:self];
    NSData *HTMLData = [HTML dataUsingEncoding:NSUTF8StringEncoding];
    return [NSAttributedString attributedStringWithHTML:HTMLData options:nil];
}

- (NSAttributedString *)nonSelectedAttributesStringFromMarkdown {
    NSString *HTML = [GHAPIMarkdownFormatter issueFormattedHTMLStringFromMarkdownString:self];
    NSData *HTMLData = [HTML dataUsingEncoding:NSUTF8StringEncoding];
    return [NSAttributedString attributedStringWithHTML:HTMLData options:nil];
}

@end





@implementation NSString (GHAPIHasing)

- (NSString *)stringFromMD5Hash {
    const char *cStr = [self UTF8String];
    unsigned char result[16];
    CC_MD5( cStr, strlen(cStr), result ); // This is the md5 call
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3], 
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];  
}

@end

