//
//  GHPullToReleaseTableHeaderView.h
//  iGithub
//
//  Created by me on 14.05.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

extern CGFloat const kGHPullToReleaseTableHeaderViewPreferedHeaderHeight;

typedef enum {
    GHPullToReleaseTableHeaderViewStateNormal,
    GHPullToReleaseTableHeaderViewStateDraggedDown,
    GHPullToReleaseTableHeaderViewStateLoading
} GHPullToReleaseTableHeaderViewState;

@interface GHPullToReleaseTableHeaderView : UIView {
@private
    UILabel *_lastUpdateLabel;
	UILabel *_statusLabel;
	CALayer *_arrowImageLayer;
	UIActivityIndicatorView *_activityIndicatorView;
    
    NSDate *_lastUpdateDate;
    
    GHPullToReleaseTableHeaderViewState _state;
}

@property (nonatomic, retain) UILabel *lastUpdateLabel;
@property (nonatomic, retain) UILabel *statusLabel;
@property (nonatomic, retain) CALayer *arrowImageLayer;
@property (nonatomic, retain) UIActivityIndicatorView *activityIndicatorView;

@property (nonatomic, retain) NSDate *lastUpdateDate;

@property (nonatomic, assign) GHPullToReleaseTableHeaderViewState state;

@end
