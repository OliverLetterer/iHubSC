//
//  ANNotificationErrorView.m
//  iGithub
//
//  Created by Oliver Letterer on 12.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "ANNotificationErrorView.h"


@implementation ANNotificationErrorView

#pragma mark - Initialization

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            self.imageView.image = [UIImage imageNamed:@"ANNotificationErrorImage@2x.png"];
        } else {
            self.imageView.image = [UIImage imageNamed:@"ANNotificationErrorImage.png"];
        }
        self.displayTime = 1.0f;
        self.backgroundView.colors = [NSArray arrayWithObjects:
                                      (__bridge id)[UIColor colorWithRed:192.0f/255.0 green:14.0f/255.0 blue:14.0f/255.0 alpha:1.0].CGColor, 
                                      (__bridge id)[UIColor colorWithRed:145.0f/255.0 green:14.0f/255.0 blue:14.0f/255.0 alpha:1.0].CGColor,
                                      nil];
    }
    return self;
}

#pragma mark - Memory management


@end
