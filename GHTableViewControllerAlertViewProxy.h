//
//  GHTableViewControllerAlertViewProxy.h
//  iGithub
//
//  Created by Oliver Letterer on 27.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GHTableViewControllerAlertViewProxy;

@protocol GHTableViewControllerAlertViewProxyDelegate

- (void)alertViewProxy:(GHTableViewControllerAlertViewProxy *)proxy alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;

@end




@interface GHTableViewControllerAlertViewProxy : NSObject {
@private
    id<GHTableViewControllerAlertViewProxyDelegate> _delegate;
    UIAlertView *_alert;
}

@property (nonatomic, assign) id<GHTableViewControllerAlertViewProxyDelegate> delegate;
@property (nonatomic, retain) UIAlertView *alert;

- (id)initWithAlertView:(UIAlertView *)alertView delegate:(id<GHTableViewControllerAlertViewProxyDelegate>)delegate;

@end
