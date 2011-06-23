//
//  INNotificationQueue+Private.h
//  Installous
//
//  Created by oliver on 08.11.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "INNotificationQueue.h"

@interface INNotificationQueue (private)

- (void)_detachNotificationItem:(INNotificationQueueItem *)item;
- (void)_displayNextNotification;

- (void)_bounceNotificationIn:(INNotificationQueueItem *)item;
- (void)_removeNotification:(INNotificationQueueItem *)item;
- (void)_removeNotificationTimerCallback:(NSTimer *)timer;
- (void)_removeNotificationDoneTimerCallback:(NSTimer *)timer;
- (void)_removeNotificationDone:(INNotificationQueueItem *)item;

@end
