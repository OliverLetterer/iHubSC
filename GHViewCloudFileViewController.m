//
//  GHViewCloudFileViewController.m
//  iGithub
//
//  Created by Oliver Letterer on 18.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHViewCloudFileViewController.h"
#import "WAHTMLMarkdownFormatter.h"

@implementation GHViewCloudFileViewController

@synthesize repository=_repository, tree=_tree, filename=_filename, relativeURL=_relativeURL;
@synthesize metadata=_metadata, contentString=_contentString, markdownString=_markdownString, contentImage=_contentImage;
@synthesize request=_request;
@synthesize scrollView=_scrollView, backgroundGradientLayer=_backgroundGradientLayer, loadingLabel=_loadingLabel, activityIndicatorView=_activityIndicatorView, progressView=_progressView, imageView=_imageView;

#pragma mark - Initialization

- (void)setMetadata:(GHFileMetaData *)metadata {
    if (metadata != _metadata) {
        [_metadata release];
        _metadata = [metadata retain];
        
        if ([_metadata.mimeType rangeOfString:@"text"].location != NSNotFound) {
            // now we need to download the text data
            [_metadata contentOfFileWithCompletionHandler:^(NSData *data, NSError *error) {
                if (error) {
                    [self handleError:error];
                } else {
                    NSString *fileString = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
                    
                    if (fileString) {
                        if ([self.filename hasSuffix:@".md"] || [self.filename hasSuffix:@".markdown"]) {
#warning parse markdown
                            NSString *formatFilePath = [[NSBundle mainBundle] pathForResource:@"MarkdownStyle" ofType:nil];
                            NSString *style = [NSString stringWithContentsOfFile:formatFilePath 
                                                                        encoding:NSUTF8StringEncoding 
                                                                           error:NULL];
                            NSMutableString *parsedString = [NSMutableString stringWithFormat:@"%@", style];
                            
                            WAHTMLMarkdownFormatter *formatter = [[[WAHTMLMarkdownFormatter alloc] init] autorelease];
                            [parsedString appendFormat:@"%@", [formatter HTMLForMarkdown:fileString]];
                            self.markdownString = parsedString;
                            [self updateViewToShowMarkdownFile];
                        } else {
                            self.contentString = fileString;
                            [self updateViewToShowPlainTextFile];
                        }
                    } else {
                        UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"") 
                                                                         message:NSLocalizedString(@"Unable to show file!", @"") 
                                                                        delegate:nil 
                                                               cancelButtonTitle:NSLocalizedString(@"OK", @"") 
                                                               otherButtonTitles:nil]
                                              autorelease];
                        [alert show];
                        [self.activityIndicatorView removeFromSuperview];
                        self.activityIndicatorView = nil;
                        self.loadingLabel.text = NSLocalizedString(@"Unable to show file", @"");
                    }
                }
            }];
        } else if ([_metadata.mimeType rangeOfString:@"image"].location != NSNotFound) {
            [self updateViewForImageDownload];
            self.request = [self.metadata requestForContent];
            self.request.delegate = self;
            [self.request setCompletionBlock:^(void) {
                self.contentImage = [[[UIImage alloc] initWithData:[self.request responseData] ] autorelease];
                [self.request clearDelegatesAndCancel];
                self.request = nil;
                [self updateViewForImageContent];
            }];
            self.request.downloadProgressDelegate = self.progressView;
            
            [self.request startAsynchronous];
        } else {
            _isMimeTypeUnkonw = YES;
            [self updateViewForUnkownMimeType];
        }
    }
}

- (id)initWithRepository:(NSString *)repository tree:(NSString *)tree filename:(NSString *)filename relativeURL:(NSString *)relativeURL {
    if ((self = [super init])) {
        self.repository = repository;
        self.tree = tree;
        self.filename = filename;
        self.relativeURL = relativeURL;
        self.title = self.filename;
        [GHFileMetaData metaDataOfFile:self.filename 
                         atRelativeURL:self.relativeURL 
                          onRepository:self.repository 
                                  tree:self.tree 
                     completionHandler:^(GHFileMetaData *metaData, NSError *error) {
                         if (error) {
                             [self handleError:error];
                         } else {
                             self.metadata = metaData;
                         }
                     }];
    }
    return self;
}

- (id)initWithFile:(NSString *)filename contentsOfFile:(NSString *)content {
    if (self == [super init]) {
        self.contentString = content;
        self.title = filename;
    }
    return self;
}

#pragma mark - Memory management

- (void)dealloc {
    [_repository release];
    [_tree release];
    [_filename release];
    [_metadata release];
    [_relativeURL release];
    [_scrollView release];
    [_backgroundGradientLayer release];
    [_loadingLabel release];
    [_activityIndicatorView release];
    [_progressView release];
    [_imageView release];
    [_markdownString release];
    [_contentString release];
    
    [_request clearDelegatesAndCancel];
    [_request release];
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)loadView {
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.backgroundGradientLayer = [CAGradientLayer layer];
    self.backgroundGradientLayer.colors = [NSArray arrayWithObjects:
                                           (id)[UIColor whiteColor].CGColor, 
                                           (id)[UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0].CGColor,
                                           nil];
    self.backgroundGradientLayer.locations = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.0], [NSNumber numberWithFloat:1.0], nil];
    self.backgroundGradientLayer.frame = self.view.bounds;
    [self.view.layer addSublayer:self.backgroundGradientLayer];
    
    self.scrollView = [[[UIScrollView alloc] initWithFrame:self.view.bounds] autorelease];
    self.scrollView.backgroundColor = [UIColor clearColor];
    self.scrollView.alwaysBounceVertical = YES;
    self.scrollView.alwaysBounceHorizontal = YES;
    self.scrollView.indicatorStyle = UIScrollViewIndicatorStyleBlack;
    self.scrollView.showsVerticalScrollIndicator = YES;
    self.scrollView.showsHorizontalScrollIndicator = YES;
    self.scrollView.contentInset = UIEdgeInsetsMake(5.0, 5.0, 5.0, 5.0);
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.scrollView.delegate = self;
    [self.view addSubview:self.scrollView];
    
    self.loadingLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0.0, 170.0, 320.0, 20.0)] autorelease];
    self.loadingLabel.backgroundColor = [UIColor clearColor];
    self.loadingLabel.textColor = [UIColor blackColor];
    self.loadingLabel.textAlignment = UITextAlignmentCenter;
    self.loadingLabel.text = NSLocalizedString(@"Downloading ...", @"");
    self.loadingLabel.font = [UIFont systemFontOfSize:17.0];
    [self.view addSubview:self.loadingLabel];
    
    self.activityIndicatorView = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray] autorelease];
    self.activityIndicatorView.center = CGPointMake(75.0, 180.0);
    [self.activityIndicatorView startAnimating];
    [self.view addSubview:self.activityIndicatorView];
    
    if (self.contentString) {
        [self updateViewToShowPlainTextFile];
    } else if (self.markdownString) {
        [self updateViewToShowMarkdownFile];
    } else if (self.contentImage) {
        [self updateViewForImageContent];
    } else if (self.request) {
        [self updateViewForImageDownload];
    } else if (_isMimeTypeUnkonw) {
        [self updateViewForUnkownMimeType];
    }
}

- (void)updateViewForUnkownMimeType {
    if (![self isViewLoaded] || !_isMimeTypeUnkonw) {
        return;
    }
    
    [self.activityIndicatorView removeFromSuperview];
    self.activityIndicatorView = nil;
    
    self.loadingLabel.text = NSLocalizedString(@"Unable to display MIME-Type", @"");
}

- (void)updateViewToShowPlainTextFile {
    if (![self isViewLoaded]) {
        return;
    }
    
    [self.scrollView removeFromSuperview];
    self.scrollView = nil;
    
    CGRect frame = CGRectMake(0.0, 0.0, 320.0, 367.0f);
    
    UITextView *textView = [[[UITextView alloc] initWithFrame:frame] autorelease];
    textView.text = self.contentString;
    textView.editable = NO;
    textView.font = [UIFont systemFontOfSize:16.0];
    textView.alwaysBounceVertical = YES;
    [self.view addSubview:textView];
}

- (void)updateViewToShowMarkdownFile {
    if (![self isViewLoaded]) {
        return;
    }
    
    [self.scrollView removeFromSuperview];
    self.scrollView = nil;
    
    CGRect frame = CGRectMake(0.0, 0.0, 320.0, 367.0f);
    
    UIWebView *webView = [[[UIWebView alloc] initWithFrame:frame] autorelease];
    [webView loadHTMLString:self.markdownString baseURL:nil];
    webView.scalesPageToFit = YES;
    [self.view addSubview:webView];
}

- (void)updateViewForImageDownload {
    if (![self isViewLoaded]) {
        return;
    }
    
    [self.backgroundGradientLayer removeFromSuperlayer];
    self.backgroundGradientLayer = nil;
    [self.activityIndicatorView removeFromSuperview];
    self.activityIndicatorView = nil;
    [self.loadingLabel removeFromSuperview];
    self.loadingLabel = nil;
    
    self.progressView = [[[DDProgressView alloc] initWithFrame:CGRectMake(20.0, 170.0, 280.0, 0.0)] autorelease];
    self.progressView.alpha = 0.0;
    [self.view addSubview:self.progressView];
    [UIView animateWithDuration:0.3 animations:^(void) {
        self.view.backgroundColor = [UIColor blackColor];
        self.progressView.alpha = 1.0;
    }];
}

- (void)updateViewForImageContent {
    if (![self isViewLoaded]) {
        return;
    }
    self.view.backgroundColor = [UIColor blackColor];
    [self.progressView removeFromSuperview];
    self.progressView = nil;
    
    [self.backgroundGradientLayer removeFromSuperlayer];
    self.backgroundGradientLayer = nil;
    [self.activityIndicatorView removeFromSuperview];
    self.activityIndicatorView = nil;
    [self.loadingLabel removeFromSuperview];
    self.loadingLabel = nil;
    
    self.imageView = [[[UIImageView alloc] initWithImage:self.contentImage] autorelease];
    [self.scrollView addSubview:self.imageView];
    [self.imageView sizeToFit];
    
    self.scrollView.contentSize = self.imageView.frame.size;
    
    if (self.scrollView.contentSize.width < self.scrollView.bounds.size.width) {
        // move image into center
        CGPoint oldCenter = self.imageView.center;
        oldCenter.x = self.scrollView.bounds.size.width / 2.0f;
        self.imageView.center = oldCenter;
    }
    
    if (self.scrollView.contentSize.height < self.scrollView.bounds.size.height) {
        CGPoint oldCenter = self.imageView.center;
        oldCenter.y = self.scrollView.bounds.size.height / 2.0f;
        self.imageView.center = oldCenter;
    }
    
    self.scrollView.minimumZoomScale = self.scrollView.bounds.size.width / self.imageView.frame.size.width;
    
    [self.scrollView setZoomScale:self.scrollView.minimumZoomScale animated:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    [_scrollView release];
    _scrollView = nil;
    [_backgroundGradientLayer release];
    _backgroundGradientLayer = nil;
    [_loadingLabel release];
    _loadingLabel = nil;
    [_activityIndicatorView release];
    _activityIndicatorView = nil;
    [_progressView release];
    _progressView = nil;
    [_imageView release];
    _imageView = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
@end
