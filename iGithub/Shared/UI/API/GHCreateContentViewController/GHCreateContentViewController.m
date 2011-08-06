//
//  GHCreateContentViewController.m
//  iGithub
//
//  Created by Oliver Letterer on 06.08.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHCreateContentViewController.h"


@implementation GHCreateContentViewController

#pragma mark - setters and getters

- (UIBarButtonItem *)loadingButton {
    if (!_loadingButton) {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            UIView *wrapperView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 49.0f, 30.0f)];
            UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"UIBarButtonItemSaveBackground~iPad.png"] ];
            [wrapperView addSubview:imageView];
            UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
            [wrapperView addSubview:activityIndicatorView];
            [activityIndicatorView startAnimating];
            activityIndicatorView.center = CGPointMake(CGRectGetMidX(wrapperView.bounds), CGRectGetMidY(wrapperView.bounds));
            _loadingButton = [[UIBarButtonItem alloc] initWithCustomView:wrapperView];
            _loadingButton.enabled = NO;
        } else {
            UIView *wrapperView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 49.0f, 30.0f)];
            UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"UIBarButtonItemSaveBackground.png"] ];
            [wrapperView addSubview:imageView];
            UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
            [wrapperView addSubview:activityIndicatorView];
            [activityIndicatorView startAnimating];
            activityIndicatorView.center = CGPointMake(CGRectGetMidX(wrapperView.bounds), CGRectGetMidY(wrapperView.bounds));
            _loadingButton = [[UIBarButtonItem alloc] initWithCustomView:wrapperView];
            _loadingButton.enabled = NO;
        }
    }
    return _loadingButton;
}

- (UIBarButtonItem *)saveButton {
    if (!_saveButton) {
        _saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave 
                                                                    target:self 
                                                                    action:@selector(saveButtonClicked:)];
    }
    return _saveButton;
}

- (UIBarButtonItem *)cancelButton {
    if (!_cancelButton) {
        _cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel 
                                                                      target:self 
                                                                      action:@selector(cancelButtonClicked:)];
    }
    return _cancelButton;
}

#pragma mark - target actions

- (void)saveButtonClicked:(UIBarButtonItem *)sender {
    
}

- (void)cancelButtonClicked:(UIBarButtonItem *)cancelButton {
    
}

#pragma mark - Initialization

- (id)init {
    if ((self = [super initWithStyle:UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? UITableViewStyleGrouped : UITableViewStylePlain])) {
        // Custom initialization
    }
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    if (!self.isPresentedInPopoverController) {
        self.navigationItem.leftBarButtonItem = self.cancelButton;
    }
    
    self.navigationItem.rightBarButtonItem = self.saveButton;
    
    self.contentSizeForViewInPopover = CGSizeMake(320.0f, 480.0f);
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    _saveButton = nil;
    _cancelButton = nil;
}

@end
