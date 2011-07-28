//
//  GHPieChartProgressView.h
//  iGithub
//
//  Created by Oliver Letterer on 05.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GHPieChartProgressView : UIView {
@private
    CGFloat _progress;
    UIColor *_tintColor;
    
    UILabel *_progressLabel;
    
    CGGradientRef _tintGradient;
}

@property (nonatomic, assign) CGFloat progress;
@property (nonatomic, retain) UIColor *tintColor;

@property (nonatomic, retain) UILabel *progressLabel;

@end
