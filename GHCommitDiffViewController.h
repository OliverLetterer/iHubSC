//
//  GHCommitDiffViewController.h
//  iGithub
//
//  Created by Oliver Letterer on 15.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "GHTextView.h"

@interface GHCommitDiffViewController : UIViewController <GHTextViewDelegate, UIScrollViewDelegate> {
@private
    NSString *_diffString;
    GHTextView *_diffView;
    UIScrollView *_scrollView;
    UILabel *_loadingLabel;
    UIActivityIndicatorView *_activityIndicatorView;
}

@property (nonatomic, copy) NSString *diffString;
@property (nonatomic, retain) GHTextView *diffView;
@property (nonatomic, retain) UIScrollView *scrollView;
@property (nonatomic, retain) UILabel *loadingLabel;
@property (nonatomic, retain) UIActivityIndicatorView *activityIndicatorView;

- (id)initWithDiffString:(NSString *)diffString;

@end
