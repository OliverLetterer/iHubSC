//
//  GHCommitDiffViewController.h
//  iGithub
//
//  Created by Oliver Letterer on 15.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "GHCommitDiffView.h"

@interface GHCommitDiffViewController : UIViewController <GHCommitDiffViewDelegate> {
@private
    NSString *_diffString;
    GHCommitDiffView *_diffView;
    UIScrollView *_scrollView;
    CAGradientLayer *_backgroundGradientLayer;
    UILabel *_loadingLabel;
    UIActivityIndicatorView *_activityIndicatorView;
}

@property (nonatomic, copy) NSString *diffString;
@property (nonatomic, retain) GHCommitDiffView *diffView;
@property (nonatomic, retain) UIScrollView *scrollView;
@property (nonatomic, retain) CAGradientLayer *backgroundGradientLayer;
@property (nonatomic, retain) UILabel *loadingLabel;
@property (nonatomic, retain) UIActivityIndicatorView *activityIndicatorView;

- (id)initWithDiffString:(NSString *)diffString;

@end
