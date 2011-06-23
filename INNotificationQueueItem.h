//
//  INNotificationQueueItem.h
//  Installous
//
//  Created by oliver on 08.11.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
	INNotificationQueueItemStyleSmallWithText = 0,
	INNotificationQueueItemStyleLargeWithImage
} INNotificationQueueItemStyle;

typedef enum {
	INNotificationQueueItemRemoveByFadingOut = 0,
	INNotificationQueueItemRemoveToDownloadsIPhone,
	INNotificationQueueItemRemoveToDownloadsIPad,
} INNotificationQueueItemRemoveStyle;

@interface INNotificationQueueItem : UIView {
  @private
	UILabel *_titleLabel;
	UILabel *_descriptionLabel;
	UIImageView *_imageView;
	UIImageView *_backgroundImageView;
	INNotificationQueueItemStyle _style;
	
	INNotificationQueueItemRemoveStyle _removeStyle;
}

@property (nonatomic, retain) UILabel *titleLabel;
@property (nonatomic, retain) UILabel *descriptionLabel;
@property (nonatomic, retain) UIImageView *imageView;

@property (assign) INNotificationQueueItemRemoveStyle removeStyle;

+ (id)itemWithStyle:(INNotificationQueueItemStyle)style;
- (id)initWithStyle:(INNotificationQueueItemStyle)style;

@end
