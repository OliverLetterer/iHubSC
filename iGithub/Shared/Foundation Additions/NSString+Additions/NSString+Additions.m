//
//  NSString+Additions.m
//  iGithub
//
//  Created by Oliver Letterer on 09.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "NSString+Additions.h"


@implementation NSString (NSFileSize)

+ (NSString *)stringFormFileSize:(long long)fileSize {
    static NSString *sizeArray[4] = {@"B", @"KB", @"MB", @"GB"};
	
	float size = fileSize * 1.0;
	int counter = 0;
	while (size > 800 && counter < 4) {
		size /= 1024.0;
		counter++;
	}
	
	return [NSString stringWithFormat:@"%0.2f %@", size, sizeArray[counter] ];
}

@end


@implementation NSString (CWAddition)
- (NSString *)stringBetweenString:(NSString *)start andString:(NSString *)end {
    NSRange startRange = [self rangeOfString:start];
    if (startRange.location != NSNotFound) {
        NSRange targetRange;
        targetRange.location = startRange.location + startRange.length;
        targetRange.length = [self length] - targetRange.location;   
        NSRange endRange = [self rangeOfString:end options:0 range:targetRange];
        if (endRange.location != NSNotFound) {
            targetRange.length = endRange.location - targetRange.location;
            return [self substringWithRange:targetRange];
        }
    }
    return nil;
}
@end
