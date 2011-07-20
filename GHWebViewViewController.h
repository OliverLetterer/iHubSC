//
//  GHWebViewViewController.h
//  iGithub
//
//  Created by Oliver Letterer on 10.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>

#warning better NSCoding support

@interface GHWebViewViewController : UIViewController <UIWebViewDelegate, UIActionSheetDelegate> {
@private
    NSURL *_URL;
    UIWebView *_webView;
}

@property (nonatomic, copy) NSURL *URL;
@property (nonatomic, retain) UIWebView *webView;

- (id)initWithURL:(NSURL *)URL;

- (void)actionButtonClicked:(UIBarButtonItem *)sender;

@end
