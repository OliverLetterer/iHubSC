//
//  ANNotificationQueue.h
//  iGithub
//
//  Created by Oliver Letterer on 12.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ANNotificationQueue : NSObject { 

}

- (void)detatchErrorNotificationWithTitle:(NSString *)title errorMessage:(NSString *)errorMessage;
- (void)detatchSuccesNotificationWithTitle:(NSString *)title message:(NSString *)errorMessage;

@end


@interface ANNotificationQueue (Singleton)

+ (ANNotificationQueue *)sharedInstance;

@end
