//
//  GHCommitDiffViewController.h
//  iGithub
//
//  Created by Oliver Letterer on 15.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface GHCommitDiffViewController : UIViewController <UIScrollViewDelegate> {
@private
    NSString *_diffString;
    NSString *_HTMLString;
    
    UIWebView *_webView;
    UIView *_topOverlayView;
}

@property (nonatomic, copy) NSString *diffString;
@property (nonatomic, copy) NSString *HTMLString;
@property (nonatomic, retain) UIWebView *webView;
@property (nonatomic, retain) UIView *topOverlayView;

- (id)initWithDiffString:(NSString *)diffString;

@end
