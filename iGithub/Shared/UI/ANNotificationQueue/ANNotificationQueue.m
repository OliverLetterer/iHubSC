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
#import "ANNotificationQueueWindow.h"

@interface ANNotificationQueue () {
@private
    NSMutableArray *_notifications;
    UIWindow *_currentWindow;
}

@property (nonatomic, retain) NSMutableArray *notifications;
@property (nonatomic, readonly) CGFloat defaultNotificationWidth;
@property (nonatomic, readonly) UIWindow *currentWindow;

- (void)_detachNotification:(ANNotificationView *)notificationView;
- (void)_displayNextNotification;

-(CAAnimation *)flipAnimationWithDuration:(NSTimeInterval)aDuration forLayerBeginningOnTop:(BOOL)beginsOnTop scaleFactor:(CGFloat)scaleFactor;

@end


CGFloat const ANNotificationQueueAnimationDuration = 0.35f*2.0f;


@implementation ANNotificationQueue
@synthesize notifications=_notifications;

#pragma mark - Initialization

- (id)init {
    if ((self = [super init])) {
        self.notifications = [NSMutableArray array];
    }
    return self;
}

#pragma mark - Instance methods

- (void)detatchErrorNotificationWithTitle:(NSString *)title errorMessage:(NSString *)errorMessage {
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        ANNotificationView *notificationView = [[ANNotificationErrorView alloc] initWithFrame:CGRectZero];
        notificationView.titleLabel.text = title;
        notificationView.detailTextLabel.text = errorMessage;
        
        [self _detachNotification:notificationView];
    });
}

- (void)detatchSuccesNotificationWithTitle:(NSString *)title message:(NSString *)errorMessage {
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        ANNotificationView *notificationView = [[ANNotificationSuccessView alloc] initWithFrame:CGRectZero];
        notificationView.titleLabel.text = title;
        notificationView.detailTextLabel.text = errorMessage;
        
        [self _detachNotification:notificationView];
    });
}

#pragma mark - Private methods

- (CGFloat)defaultNotificationWidth {
    CGFloat width = 0.0f;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        width = 500.0f;
    } else {
        width = 280.0f;
    }
    
    return width;
}

- (UIWindow *)currentWindow {
    if (!_currentWindow) {
        _currentWindow = [[ANNotificationQueueWindow alloc] initWithFrame:[UIApplication sharedApplication].delegate.window.frame];
        self.currentWindow.alpha = 0.0f;
    }
    return _currentWindow;
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

- (void)_displayNextNotification {
    if ([self.notifications count] == 0) {
        [_currentWindow resignKeyWindow];
        [[UIApplication sharedApplication].delegate.window makeKeyAndVisible];
        [UIView animateWithDuration:0.5f animations:^(void) {
            _currentWindow.alpha = 0.0f;
        }];
		return;
	}
    [self.currentWindow makeKeyAndVisible];
    [UIView animateWithDuration:0.5f animations:^(void) {
        self.currentWindow.alpha = 1.0f;
    }];
	
	ANNotificationView *notificationView = [self.notifications objectAtIndex:0];
    CGSize size = [notificationView sizeThatFits:CGSizeMake(self.defaultNotificationWidth, MAXFLOAT)];
    CGRect frame = notificationView.frame;
    frame.size = size;
    notificationView.frame = frame;
    notificationView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    
    
    UIView *topContainerView = self.currentWindow.rootViewController.view;
    
    UIView *containerView = [[UIView alloc] initWithFrame:topContainerView.bounds];
    containerView.backgroundColor = [UIColor clearColor];
    containerView.userInteractionEnabled = NO;
    [containerView addSubview:notificationView];
    [topContainerView addSubview:containerView];
    
    CGPoint centerPoint = CGPointMake(CGRectGetWidth(containerView.bounds)/2.0f, CGRectGetHeight(containerView.bounds)/2.0f);
    notificationView.center = centerPoint;
    
    CALayer *bottomLayer = notificationView.layer;
    
    CGFloat zDistance = 1500.0f;
    CATransform3D perspective = CATransform3DIdentity; 
    perspective.m34 = -1.0f / zDistance;
    bottomLayer.transform = perspective;
    
    [bottomLayer addAnimation:[self flipAnimationWithDuration:ANNotificationQueueAnimationDuration forLayerBeginningOnTop:NO scaleFactor:2.0f] forKey:nil];
    
    double delayInSeconds = notificationView.displayTime + ANNotificationQueueAnimationDuration;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
        [bottomLayer addAnimation:[self flipAnimationWithDuration:ANNotificationQueueAnimationDuration forLayerBeginningOnTop:YES scaleFactor:2.0f] forKey:nil];
        
        double delayInSeconds = ANNotificationQueueAnimationDuration;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            // now remove animation is done, remove notificaiton and display next
            topContainerView.userInteractionEnabled = YES;
            [containerView removeFromSuperview];
            [self.notifications removeObjectAtIndex:0];
            [self _displayNextNotification];
        });
    });
}

-(CAAnimation *)flipAnimationWithDuration:(NSTimeInterval)aDuration forLayerBeginningOnTop:(BOOL)beginsOnTop scaleFactor:(CGFloat)scaleFactor {
    // Rotating halfway (pi radians) around the Y axis gives the appearance of flipping
    CABasicAnimation *flipAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.y"];
    CGFloat startValue = beginsOnTop ? 0.0f : M_PI;
    CGFloat endValue = beginsOnTop ? -M_PI : 0.0f;
    flipAnimation.fromValue = [NSNumber numberWithDouble:startValue];
    flipAnimation.toValue = [NSNumber numberWithDouble:endValue];
    
    // Shrinking the view makes it seem to move away from us, for a more natural effect
    // Can also grow the view to make it move out of the screen
    startValue = beginsOnTop ? 1.0f : 0.05f;
    endValue = beginsOnTop ? 0.05f : 1.0f;
    CAKeyframeAnimation *sizeAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    sizeAnimation.values = [NSArray arrayWithObjects:[NSNumber numberWithFloat:startValue], 
                            [NSNumber numberWithFloat:scaleFactor],
                            [NSNumber numberWithFloat:endValue],
                            nil];
    
    // Combine the flipping and shrinking into one smooth animation
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    animationGroup.animations = [NSArray arrayWithObjects:flipAnimation, sizeAnimation, nil];
    
    // As the edge gets closer to us, it appears to move faster. Simulate this in 2D with an easing function
    animationGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animationGroup.duration = aDuration;
    
    // Hold the view in the state reached by the animation until we can fix it, or else we get an annoying flicker
	// this really means keep the state of the object at whatever the anim ends at
    animationGroup.fillMode = kCAFillModeForwards;
    animationGroup.removedOnCompletion = NO;
    
    return animationGroup;
}

@end





#pragma mark - Singleton implementation

static ANNotificationQueue *_instance = nil;

@implementation ANNotificationQueue (Singleton)

+ (ANNotificationQueue *)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[super allocWithZone:NULL] init];
    });
    return _instance;
}

+ (id)allocWithZone:(NSZone *)zone {	
	return [self sharedInstance];	
}


- (id)copyWithZone:(NSZone *)zone {
    return self;	
}

@end
