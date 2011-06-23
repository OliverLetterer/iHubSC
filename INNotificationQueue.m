//
//  INNotificationQueue.m
//  Installous
//
//  Created by oliver on 08.11.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "INNotificationQueue.h"
#import "INNotificationQueue+Private.h"

static INNotificationQueue *singletonINNotificationQueue = nil;

@implementation INNotificationQueue

@synthesize notificationView=_notificationView, notificationCenterPoint=_notificationCenterPoint, notifications=_notifications;

#pragma mark -
#pragma mark singleton pattern

+(INNotificationQueue*)sharedQueue {
	@synchronized(self) {
		if (!singletonINNotificationQueue) {
			singletonINNotificationQueue = [[INNotificationQueue alloc] init];
		}
	}
	return singletonINNotificationQueue;
}

- (id)retain {
	return self;
}

- (void)release { }

- (id)autorelease {
	return self;
}

- (unsigned)retainCount {
	return UINT_MAX;
}

#pragma mark -
#pragma mark instance methods

- (id)init {
    if ((self = [super init])) {
        self.notifications = [NSMutableArray array];
    }
    return self;
}

- (void)detachLargeNotificationWithImage:(UIImage *)image andTitle:(NSString *)title removeStyle:(INNotificationQueueItemRemoveStyle)removeStyle {
	if (title == nil) {
		return;
	}
	INNotificationQueueItem *item = [INNotificationQueueItem itemWithStyle:INNotificationQueueItemStyleLargeWithImage];
	
	item.imageView.image = image;
	item.titleLabel.text = title;
	item.removeStyle = removeStyle;
	
	[self performSelectorOnMainThread:@selector(_detachNotificationItem:) withObject:item waitUntilDone:NO];
}

- (void)detachSmallNotificationWithTitle:(NSString *)title andSubtitle:(NSString *)subtitle removeStyle:(INNotificationQueueItemRemoveStyle)removeStyle {
	if ((!title && !subtitle) || ([[title stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@""] && [[subtitle stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@""])) {
		return;
	}
	
	INNotificationQueueItem *item = [INNotificationQueueItem itemWithStyle:INNotificationQueueItemStyleSmallWithText];
	
	item.descriptionLabel.text = subtitle;
	item.titleLabel.text = title;
	item.removeStyle = removeStyle;
	
	[self performSelectorOnMainThread:@selector(_detachNotificationItem:) withObject:item waitUntilDone:NO];
}

@end
