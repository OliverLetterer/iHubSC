//
//  INNotificationQueue.h
//  Installous
//
//  Created by oliver on 08.11.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "INNotificationQueueItem.h"

@interface INNotificationQueue : NSObject {
  @private
	UIView *_notificationView;
	CGPoint _notificationCenterPoint;
	NSMutableArray *_notifications;
}

@property (retain) UIView *notificationView;
@property (assign) CGPoint notificationCenterPoint;
@property (retain) NSMutableArray *notifications;

+(INNotificationQueue*)sharedQueue;

- (void)detachLargeNotificationWithImage:(UIImage *)image andTitle:(NSString *)title removeStyle:(INNotificationQueueItemRemoveStyle)removeStyle;
- (void)detachSmallNotificationWithTitle:(NSString *)title andSubtitle:(NSString *)subtitle removeStyle:(INNotificationQueueItemRemoveStyle)removeStyle;

@end
