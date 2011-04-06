//
//  EGORefreshTableHeaderView.h
//  Demo
//
//  Created by Devin Doty on 10/14/09October14.
//  Copyright 2009 enormego. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface EGORefreshTableHeaderView : UIView {
@private
	UILabel *_lastUpdatedLabel;
	UILabel *_statusLabel;
	UIImageView *_arrowImage;
	UIActivityIndicatorView *_activityView;
	NSDate *_lastUpdatedDate;
	BOOL _isFlipped;
}

@property(nonatomic,retain)NSDate *lastUpdatedDate;
@property BOOL isFlipped;

@property (nonatomic, retain) UILabel *lastUpdatedLabel;
@property (nonatomic, retain) UILabel *statusLabel;
@property (nonatomic, retain) UIImageView *arrowImage;
@property (nonatomic, retain) UIActivityIndicatorView *activityView;

- (void)flipImageAnimated:(BOOL)animated;
- (void)toggleActivityView:(BOOL)isON;
- (void)setStatus:(int)status;

@end