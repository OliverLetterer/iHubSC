//
//  INNotificationQueue+Private.m
//  Installous
//
//  Created by oliver on 08.11.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "INNotificationQueue+Private.h"
#import <QuartzCore/QuartzCore.h>

@implementation INNotificationQueue (private)

#pragma mark -
#pragma mark managing notifications

- (void)_detachNotificationItem:(INNotificationQueueItem *)item {
	BOOL startNotifications = NO;
	
	if ([self.notifications count] == 0) {
		startNotifications = YES;
	}
	
	[self.notifications addObject:item];
	
	if (startNotifications) {
		[self _displayNextNotification];
	}
}

- (void)_displayNextNotification {
	if ([self.notifications count] <= 0) {
		return;
	}
	
	INNotificationQueueItem *item = [self.notifications objectAtIndex:0];
	[self _bounceNotificationIn:item];
}

#pragma mark -
#pragma mark animating notifications

- (void)_bounceNotificationIn:(INNotificationQueueItem *)item {
	item.center = self.notificationCenterPoint;
	[self.notificationView addSubview:item];
	
	CAKeyframeAnimation *bounceAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
	bounceAnimation.calculationMode = kCAAnimationLinear;
	
	bounceAnimation.values = [NSArray arrayWithObjects:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.1, 0.1, 1.0)],
													[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.5, 1.5, 1.0)],
													[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)],
													nil
						   ];
	
	bounceAnimation.duration = 0.35;
	
	[item.layer addAnimation:bounceAnimation forKey:@"transform"];
	
	[NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(_removeNotificationTimerCallback:) userInfo:item repeats:NO];
}

- (void)_removeNotificationTimerCallback:(NSTimer *)timer {
	[self _removeNotification: [timer userInfo]];
}

- (void)_removeNotification:(INNotificationQueueItem *)item {
	switch (item.removeStyle) {
		case INNotificationQueueItemRemoveByFadingOut:
			;
			
			CAKeyframeAnimation *sizeAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
			sizeAnimation.calculationMode = kCAAnimationLinear;
			
			sizeAnimation.values = [NSArray arrayWithObjects:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)],
									 [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.2, 1.2, 1.0)],
									 [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.01, 0.01, 1.0)],
									 nil];
			
			sizeAnimation.duration = 0.35;
			
			[item.layer addAnimation:sizeAnimation forKey:@"transform"];
			
			item.layer.transform = CATransform3DMakeScale(0.0, 0.0, 0.0);
			
			[NSTimer scheduledTimerWithTimeInterval:0.35 target:self selector:@selector(_removeNotificationDoneTimerCallback:) userInfo:item repeats:NO];
			
			break;
		case INNotificationQueueItemRemoveToDownloadsIPad:
			;
			
			CAKeyframeAnimation *posAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
			posAnimation.calculationMode = kCAAnimationCubic;
			
			posAnimation.values = [NSArray arrayWithObjects:[NSValue valueWithCGPoint:item.center],
								   [NSValue valueWithCGPoint:CGPointMake(70+320, 162+35)],
								   [NSValue valueWithCGPoint:CGPointMake(50+320, 35)],
								   nil];
			
			posAnimation.duration = 0.5;
			
			CAKeyframeAnimation *sizeAnimation2 = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
			sizeAnimation2.calculationMode = kCAAnimationLinear;
			
			sizeAnimation2.values = [NSArray arrayWithObjects:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)],
									 [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.2, 1.2, 1.0)],
									 [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.01, 0.01, 1.0)],
									 nil];
			
			sizeAnimation2.duration = 0.5;
			
			item.layer.position = CGPointMake(5000, 5000);
			
			[item.layer addAnimation:posAnimation forKey:@"position"];
			[item.layer addAnimation:sizeAnimation2 forKey:@"transform"];
			
			[NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(_removeNotificationDoneTimerCallback:) userInfo:item repeats:NO];
			
			break;
		case INNotificationQueueItemRemoveToDownloadsIPhone:
			;
			
			CAKeyframeAnimation *posAnimation2 = [CAKeyframeAnimation animationWithKeyPath:@"position"];
			posAnimation2.calculationMode = kCAAnimationCubic;
			
			posAnimation2.values = [NSArray arrayWithObjects:[NSValue valueWithCGPoint:item.center],
								   [NSValue valueWithCGPoint:CGPointMake(item.center.x + 70, item.center.y - 50)],
								   [NSValue valueWithCGPoint:CGPointMake(item.center.x + 70, item.center.y + 300)],
								   nil];
			
			posAnimation2.duration = 0.5;
			
			CAKeyframeAnimation *sizeAnimation3 = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
			sizeAnimation3.calculationMode = kCAAnimationLinear;
			
			sizeAnimation3.values = [NSArray arrayWithObjects:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)],
															[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.2, 1.2, 1.0)],
															[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.01, 0.01, 1.0)],
								   nil];
			
			sizeAnimation3.duration = 0.5;
			
			item.layer.position = CGPointMake(5000, 5000);
			
			[item.layer addAnimation:posAnimation2 forKey:@"position"];
			[item.layer addAnimation:sizeAnimation3 forKey:@"transform"];
			
			[NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(_removeNotificationDoneTimerCallback:) userInfo:item repeats:NO];
			
			break;
		default:
			break;
	}
}

- (void)_removeNotificationDoneTimerCallback:(NSTimer *)timer {
	[self _removeNotificationDone:[timer userInfo]];
}

- (void)_removeNotificationDone:(INNotificationQueueItem *)item {
	@try {
		[item removeFromSuperview];
		[self.notifications removeObjectAtIndex:0];
		[self _displayNextNotification];
	}
	@catch (NSException * e) {
		UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error") 
														 message:[e description] 
														delegate:nil 
											   cancelButtonTitle:NSLocalizedString(@"OK", @"OK") 
											   otherButtonTitles:nil]
							  autorelease];
		[alert show];
	}
}

@end
