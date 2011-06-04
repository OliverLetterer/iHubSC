//
//  INProgressView.h
//  GradientSample
//
//  Created by oliver on 26.12.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface INProgressView : UIView {
	CGFloat _progress;
	CGRect _progressRect;
	
	UIColor *_progressBarBackgroundColor;
	UIColor *_progressBarTintColor;
	UIColor *_tintColor;
	
	id _outerPath;
	id _innerPath;
}

@property (nonatomic, assign) CGFloat progress;

@property (nonatomic, retain) id outerPath;
@property (nonatomic, retain) id innerPath;

@property (nonatomic, retain) UIColor *progressBarBackgroundColor;
@property (nonatomic, retain) UIColor *progressBarTintColor;
@property (nonatomic, retain) UIColor *tintColor;

@end
