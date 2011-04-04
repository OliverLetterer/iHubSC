//
//  NSDate+Additions.m
//  iGithub
//
//  Created by Oliver Letterer on 04.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "NSDate+Additions.h"


@implementation NSDate (GHPrettyTimeinterval)

- (NSString *)prettyTimeIntervalSinceNow {
    static NSString *valuesArray[] = {@"seconds", @"minutes", @"hours", @"days", @"years"};
    static NSUInteger timeDiffs[] = {60, 3600, 86400, 31536000};
    
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
    
    return [NSString stringWithFormat:@"%d %@", difference, valuesArray[index]];
}

@end
