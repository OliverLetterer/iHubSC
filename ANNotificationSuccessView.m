//
//  ANNotificationSuccessView.m
//  iGithub
//
//  Created by Oliver Letterer on 12.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "ANNotificationSuccessView.h"


@implementation ANNotificationSuccessView

#pragma mark - Initialization

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            self.imageView.image = [UIImage imageNamed:@"ANNotificationSuccessImage@2x.png"];
        } else {
            self.imageView.image = [UIImage imageNamed:@"ANNotificationSuccessImage.png"];
        }
        self.displayTime = 1.0f;
        self.backgroundView.colors = [NSArray arrayWithObjects:
                                      (id)[UIColor colorWithRed:19.0f/255.0 green:146.0f/255.0 blue:16.0f/255.0 alpha:1.0].CGColor, 
                                      (id)[UIColor colorWithRed:16.0f/255.0 green:116.0f/255.0 blue:13.0f/255.0 alpha:1.0].CGColor,
                                      nil];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

#pragma mark - Memory management

- (void)dealloc {
    
    [super dealloc];
}

@end
