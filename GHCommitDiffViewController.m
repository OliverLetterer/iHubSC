//
//  GHCommitDiffViewController.m
//  iGithub
//
//  Created by Oliver Letterer on 15.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHCommitDiffViewController.h"
#import "UITableViewCellWithLinearGradientBackgroundView.h"

@implementation GHCommitDiffViewController

@synthesize diffString=_diffString;
@synthesize diffView=_diffView, scrollView=_scrollView, backgroundGradientLayer=_backgroundGradientLayer, loadingLabel=_loadingLabel, activityIndicatorView=_activityIndicatorView;

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
    [_diffView release];
    [_scrollView release];
    [_backgroundGradientLayer release];
    [_loadingLabel release];
    [_activityIndicatorView release];
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
    self.scrollView.indicatorStyle = UIScrollViewIndicatorStyleBlack;
    self.scrollView.showsVerticalScrollIndicator = YES;
    self.scrollView.showsHorizontalScrollIndicator = YES;
    self.scrollView.contentInset = UIEdgeInsetsMake(5.0, 5.0, 5.0, 5.0);
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.scrollView.delegate = self;
    [self.view addSubview:self.scrollView];
    
    self.diffView = [[[GHCommitDiffView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 300.0) 
                                                  diffString:self.diffString 
                                                    delegate:self] 
                     autorelease];
    [self.scrollView addSubview:self.diffView];
    
    self.loadingLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0.0, 170.0, 320.0, 20.0)] autorelease];
    self.loadingLabel.backgroundColor = [UIColor clearColor];
    self.loadingLabel.textColor = [UIColor blackColor];
    self.loadingLabel.textAlignment = UITextAlignmentCenter;
    self.loadingLabel.text = NSLocalizedString(@"Parsing ...", @"");
    self.loadingLabel.font = [UIFont systemFontOfSize:17.0];
    [self.view addSubview:self.loadingLabel];
    
    self.activityIndicatorView = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray] autorelease];
    self.activityIndicatorView.center = CGPointMake(100.0, 180.0);
    [self.activityIndicatorView startAnimating];
    [self.view addSubview:self.activityIndicatorView];
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
    
    [_diffView release];
    _diffView = nil;
    [_scrollView release];
    _scrollView = nil;
    [_backgroundGradientLayer release];
    _backgroundGradientLayer = nil;
    [_loadingLabel release];
    _loadingLabel = nil;
    [_activityIndicatorView release];
    _activityIndicatorView = nil;
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

#pragma mark - GHCommitDiffViewDelegate

- (void)commitDiffViewDidParseText:(GHCommitDiffView *)commitDiffView {
    [self.activityIndicatorView removeFromSuperview];
    self.activityIndicatorView = nil;
    [self.loadingLabel removeFromSuperview];
    self.loadingLabel = nil;
    [self.diffView sizeToFit];
    
    self.scrollView.contentSize = self.diffView.frame.size;
    self.scrollView.minimumZoomScale = self.scrollView.bounds.size.width / self.diffView.frame.size.width;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.diffView;
}

@end
