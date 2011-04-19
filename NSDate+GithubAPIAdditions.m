//
//  NSDate+GithubAPIAdditions.m
//  iGithub
//
//  Created by Oliver Letterer on 05.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "NSDate+GithubAPIAdditions.h"


@implementation NSDate (GHAPIDateFormatting)

- (NSString *)prettyTimeIntervalSinceNow {
    static NSString *valuesArray[] = {@"second", @"minute", @"hour", @"day", @"year"};
    static NSUInteger timeDiffs[] = {            60,        3600,    86400,  31536000};
    
    NSString *unit = nil;
    
    NSUInteger timeInterval = abs([self timeIntervalSinceNow]);
    
    NSUInteger index = 0;
    NSUInteger difference = 0;
    if (timeInterval > timeDiffs[3]) {
        index = 4;
        difference = timeInterval / timeDiffs[3];
    } else if (timeInterval > timeDiffs[2]) {
        index = 3;
        difference = timeInterval / timeDiffs[2];
    } else if (timeInterval > timeDiffs[1]) {
        index = 2;
        difference = timeInterval / timeDiffs[1];
    } else if (timeInterval > timeDiffs[0]) {
        index = 1;
        difference = timeInterval / timeDiffs[0];
    } else {
        index = 0;
        difference = timeInterval;
    }
    
    unit = valuesArray[index];
    
    if (difference != 1) {
        unit = [unit stringByAppendingString:@"s"];
    }
    
    return [NSString stringWithFormat:@"%d %@", difference, unit];
}

- (NSString *)stringInGithubAPIFormat {
    NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
    [formatter setDateFormat:@"yyyy/MM/dd HH:mm:ss ZZZ"];
    
    return [formatter stringFromDate:self];
}

@end
