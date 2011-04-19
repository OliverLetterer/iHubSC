//
//  GHViewCloudFileViewController.h
//  iGithub
//
//  Created by Oliver Letterer on 18.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "GithubAPI.h"
#import "UIViewController+GHErrorHandling.h"
#import "GHTextView.h"
#import "DDProgressView.h"

@interface GHViewCloudFileViewController : UIViewController <GHTextViewDelegate, UIScrollViewDelegate, ASIProgressDelegate> {
@private
    NSString *_repository;
    NSString *_tree;
    NSString *_filename;
    NSString *_relativeURL;
    
    GHFileMetaData *_metadata;
    NSString *_contentString;
    UIImage *_contentImage;
    
    ASIHTTPRequest *_request;
    
    GHTextView *_textView;
    UIScrollView *_scrollView;
    CAGradientLayer *_backgroundGradientLayer;
    UILabel *_loadingLabel;
    UIActivityIndicatorView *_activityIndicatorView;
    DDProgressView *_progressView;
    UIImageView *_imageView;
}

@property (nonatomic, copy) NSString *repository;
@property (nonatomic, copy) NSString *tree;
@property (nonatomic, copy) NSString *filename;
@property (nonatomic, copy) NSString *relativeURL;

@property (nonatomic, retain) GHFileMetaData *metadata;
@property (nonatomic, copy) NSString *contentString;
@property (nonatomic, retain) UIImage *contentImage;

@property (nonatomic, retain) ASIHTTPRequest *request;

@property (nonatomic, retain) GHTextView *textView;
@property (nonatomic, retain) UIScrollView *scrollView;
@property (nonatomic, retain) CAGradientLayer *backgroundGradientLayer;
@property (nonatomic, retain) UILabel *loadingLabel;
@property (nonatomic, retain) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, retain) DDProgressView *progressView;
@property (nonatomic, retain) UIImageView *imageView;

- (id)initWithRepository:(NSString *)repository tree:(NSString *)tree filename:(NSString *)filename relativeURL:(NSString *)relativeURL;

- (void)updateViewToShowPlainTextFile;
- (void)updateViewForImageDownload;
- (void)updateViewForImageContent;

@end
