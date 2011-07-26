//
//  GHWebViewViewController.m
//  iGithub
//
//  Created by Oliver Letterer on 10.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHWebViewViewController.h"
#import "GithubAPI.h"

@implementation GHWebViewViewController

@synthesize URL=_URL, webView=_webView;

#pragma mark - Initialization

- (id)initWithURL:(NSURL *)URL {
    if ((self = [super init])) {
        self.URL = URL;
        _canShowActionSheet = YES;
    }
    return self;
}

#pragma mark - Memory management

- (void)dealloc {
    [_URL release];
    [_webView release];
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - target actions

- (void)willPresentActionSheet:(UIActionSheet *)actionSheet {
    _canShowActionSheet = NO;
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    _canShowActionSheet = YES;
}

- (void)actionButtonClicked:(UIBarButtonItem *)sender {
    UIActionSheet *sheet = [[[UIActionSheet alloc] initWithTitle:[self.webView.request.URL absoluteString]
                                                        delegate:self 
                                               cancelButtonTitle:NSLocalizedString(@"Cancel", @"") 
                                          destructiveButtonTitle:nil 
                                               otherButtonTitles:NSLocalizedString(@"Launch Safari", @""), nil]
                            autorelease];
    sheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        if (_canShowActionSheet) {
            [sheet showFromBarButtonItem:sender animated:YES];
        }
    } else {
        [sheet showInView:self.tabBarController.view];
    }
}

#pragma mark - View lifecycle

- (void)loadView {
    self.webView = [[[UIWebView alloc] init] autorelease];
    self.webView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.webView.delegate = self;
    self.webView.scalesPageToFit = YES;
    self.view = self.webView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.webView loadRequest:[NSURLRequest requestWithURL:self.URL] ];
    
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction 
                                                                                            target:self 
                                                                                            action:@selector(actionButtonClicked:)]
                                              autorelease];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    [_webView release];
    _webView = nil;
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    self.title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    
    self.URL = webView.request.URL;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"") 
                                                 message:[error localizedDescription] 
                                                delegate:nil 
                                       cancelButtonTitle:NSLocalizedString(@"OK", @"") 
                                       otherButtonTitles:nil]
                      autorelease];
    [alert show];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        // Launch Safari clicked
        [[UIApplication sharedApplication] openURL:self.webView.request.URL];
    }
}

#pragma mark - Keyed Archiving

- (void)encodeWithCoder:(NSCoder *)encoder {
    [super encodeWithCoder:encoder];
    [encoder encodeObject:_URL forKey:@"uRL"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super initWithCoder:decoder])) {
        _URL = [[decoder decodeObjectForKey:@"uRL"] retain];
        _canShowActionSheet = YES;
    }
    return self;
}

@end
