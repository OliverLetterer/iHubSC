//
//  ANNotificationQueue.m
//  iGithub
//
//  Created by Oliver Letterer on 12.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <dispatch/dispatch.h>

#import "ANNotificationQueue.h"

#import "ANNotificationView.h"
#import "ANNotificationErrorView.h"
#import "ANNotificationSuccessView.h"

@interface ANNotificationQueue () {
@private
    NSMutableArray *_notifications;
}

@property (nonatomic, retain) NSMutableArray *notifications;
@property (nonatomic, readonly) CGRect defaultNotificationFrame;

- (void)_detachNotification:(ANNotificationView *)notificationView;
- (void)_displayNextNotification;

@end


CGFloat const ANNotificationQueueAnimationDuration = 0.35f;


@implementation ANNotificationQueue
@synthesize notifications=_notifications;

#pragma mark - Initialization

- (id)init {
    if ((self = [super init])) {
        self.notifications = [NSMutableArray array];
    }
    return self;
}

#pragma mark - Memory management

- (void)dealloc {
    [_notifications release];
    
    [super dealloc];
}

#pragma mark - Instance methods

- (void)detatchErrorNotificationWithTitle:(NSString *)title errorMessage:(NSString *)errorMessage {
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        ANNotificationView *notificationView = [[[ANNotificationErrorView alloc] initWithFrame:self.defaultNotificationFrame] autorelease];
        notificationView.titleLabel.text = title;
        notificationView.detailTextLabel.text = errorMessage;
        
        [self _detachNotification:notificationView];
    });
}

- (void)detatchSuccesNotificationWithTitle:(NSString *)title message:(NSString *)errorMessage {
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        ANNotificationView *notificationView = [[[ANNotificationSuccessView alloc] initWithFrame:self.defaultNotificationFrame] autorelease];
        notificationView.titleLabel.text = title;
        notificationView.detailTextLabel.text = errorMessage;
        
        [self _detachNotification:notificationView];
    });
}

#pragma mark - Private methods

- (CGRect)defaultNotificationFrame {
    CGRect frame = CGRectZero;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        frame.size.width = 500.0f;
        frame.size.height = 125.0f;
    } else {
        frame.size.width = 280.0f;
        frame.size.height = 125.0f;
    }
    
    return frame;
}

- (void)_detachNotification:(ANNotificationView *)notificationView {
    if (!notificationView) {
        return;
    }
    [self.notifications addObject:notificationView];
    
    if (self.notifications.count == 1) {
        // this is the only notification
        [self _displayNextNotification];
    }
}

#warning new animation for Notifications, let the view fall down from top and fall further down to disappear

- (void)_displayNextNotification {
    if ([self.notifications count] == 0) {
		return;
	}
	
	ANNotificationView *notificationView = [self.notifications objectAtIndex:0];
    notificationView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    
    UIView *containerView = [[UIApplication sharedApplication].delegate window].rootViewController.view;
    CGPoint centerPoint = CGPointMake(CGRectGetWidth(containerView.bounds)/2.0f, CGRectGetHeight(containerView.bounds)/2.0f);
    
    notificationView.center = centerPoint;
	[containerView addSubview:notificationView];
	
	CAKeyframeAnimation *bounceAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
	bounceAnimation.calculationMode = kCAAnimationCubic;
	
	bounceAnimation.values = [NSArray arrayWithObjects:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.1, 0.1, 1.0)],
                              [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.5, 1.5, 1.0)],
                              [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)],
                              nil
                              ];
	
	bounceAnimation.duration = ANNotificationQueueAnimationDuration;
	
	[notificationView.layer addAnimation:bounceAnimation forKey:@"transform"];
	
    double delayInSeconds = notificationView.displayTime + ANNotificationQueueAnimationDuration;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
        // displaying the notification is done, now remove it animated
        CAKeyframeAnimation *sizeAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
        sizeAnimation.calculationMode = kCAAnimationCubic;
        
        sizeAnimation.values = [NSArray arrayWithObjects:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)],
                                [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.2, 1.2, 1.0)],
                                [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.01, 0.01, 1.0)],
                                nil];
        
        sizeAnimation.duration = 0.35f;
        
        [notificationView.layer addAnimation:sizeAnimation forKey:@"transform"];
        
        notificationView.layer.transform = CATransform3DMakeScale(0.0, 0.0, 0.0);
        
        double delayInSeconds = ANNotificationQueueAnimationDuration;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            // now remove animation is done, remove notificaiton and display next
            [notificationView removeFromSuperview];
            [self.notifications removeObjectAtIndex:0];
            [self _displayNextNotification];
        });
    });
}

@end





#pragma mark - Singleton implementation

static ANNotificationQueue *_instance = nil;

@implementation ANNotificationQueue (Singleton)

+ (ANNotificationQueue *)sharedInstance {
	@synchronized(self) {
		
        if (!_instance) {
            _instance = [[super allocWithZone:NULL] init];
        }
    }
    return _instance;
}

+ (id)allocWithZone:(NSZone *)zone {	
	return [[self sharedInstance] retain];	
}


- (id)copyWithZone:(NSZone *)zone {
    return self;	
}

- (id)retain {	
    return self;	
}

- (NSUInteger)retainCount {
    return NSUIntegerMax;
}

- (void)release {
    //do nothing
}

- (id)autorelease {
    return self;	
}

@end
