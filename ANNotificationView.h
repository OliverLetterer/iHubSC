//
//  ANNotificationView.h
//  iGithub
//
//  Created by Oliver Letterer on 12.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ANNotificationViewBackgroundView.h"

@interface ANNotificationView : UIView {
@private
    CGFloat _displayTime;
    
    ANNotificationViewBackgroundView *_backgroundView;
    
    UILabel *_titleLabel;
    UILabel *_detailTextLabel;
    UIImageView *_imageView;
}

@property (nonatomic, assign) CGFloat displayTime;
@property (nonatomic, retain) ANNotificationViewBackgroundView *backgroundView;

@property (nonatomic, retain) UILabel *titleLabel;
@property (nonatomic, retain) UILabel *detailTextLabel;
@property (nonatomic, retain) UIImageView *imageView;

@end
