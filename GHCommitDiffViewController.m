//
//  GHCommitDiffViewController.m
//  iGithub
//
//  Created by Oliver Letterer on 15.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHCommitDiffViewController.h"
#import "UITableViewCellWithLinearGradientBackgroundView.h"
#import "GHLinearGradientBackgroundView.h"
#import "BGPlainWebView.h"

@implementation GHCommitDiffViewController

@synthesize diffString=_diffString, HTMLString=_HTMLString;
@synthesize webView=_webView, topOverlayView=_topOverlayView;

#pragma mark - setters and getters

- (void)setDiffString:(NSString *)diffString {
    [_diffString release];
    _diffString = [diffString copy];
    
    // Now do the HTML magic
    NSMutableString *HTMLString = [NSMutableString stringWithString:@""];
    [HTMLString appendString:@"<body style=\"background: -webkit-gradient(linear, left top, left bottom, from(#f0f0f0), to(#c0c0c0));\"><pre>"];
    [_diffString enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {
        NSString *textColor = @"black";
        
        if ([line hasPrefix:@"---"] || [line hasPrefix:@"-"]) {
            textColor = @"red";
        } else if ([line hasPrefix:@"+++"] || [line hasPrefix:@"+"]) {
            textColor = @"\"#1b860b\"";
        } else if ([line hasPrefix:@"@@"]) {
            textColor = @"gray";
        }
        
        [HTMLString appendFormat:@"<font color=%@ face=\"Verdana\">%@</font><br>", textColor, line];
    }];
    [HTMLString appendString:@"</pre></body>"];
    
    self.HTMLString = HTMLString;
}

#pragma mark - Initialization

- (id)initWithDiffString:(NSString *)diffString {
    if ((self = [super init])) {
        self.diffString = diffString;
    }
    return self;
}

#pragma mark - Memory management

- (void)dealloc {
    [_diffString release];
    [_HTMLString release];
    [_webView release];
    [_topOverlayView release];
    
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
    self.view = [[[GHLinearGradientBackgroundView alloc] initWithFrame:CGRectZero] autorelease];
    
    self.topOverlayView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
    self.topOverlayView.backgroundColor = [UIColor colorWithRed:240.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:1.0];
    [self.view addSubview:self.topOverlayView];
    
    self.webView = [[[BGPlainWebView alloc] initWithFrame:self.view.bounds] autorelease];
    self.webView.backgroundColor = [UIColor clearColor];
    self.webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.webView loadHTMLString:self.HTMLString baseURL:nil];
    [self.view addSubview:self.webView];
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
    
    [_webView release];
    _webView = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.topOverlayView.frame = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds)/2.0f);
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
