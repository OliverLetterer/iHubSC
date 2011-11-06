//
//  GHPOwnersNewsFeedViewController.h
//  iGithub
//
//  Created by Oliver Letterer on 10.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GHPNewsFeedViewController.h"

@interface GHPOwnersNewsFeedViewController : GHPNewsFeedViewController <NSCoding> {
@private
    NSString *_lastKnownEventDateString;
    
    BOOL _isDownloadingNewsFeedData;
}

- (void)downloadNewEventsAfterLastKnownEventDateString:(NSString *)lastKnownEventDateString; // overwrite
- (void)appendNewEvents:(NSArray *)newEvents;   // call when done

@end
