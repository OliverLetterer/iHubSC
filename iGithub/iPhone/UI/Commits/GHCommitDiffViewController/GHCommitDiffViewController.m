//
//  GHCommitDiffViewController.m
//  iGithub
//
//  Created by Oliver Letterer on 15.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHCommitDiffViewController.h"
#import "GHTableViewCellWithLinearGradientBackgroundView.h"
#import "GHLinearGradientBackgroundView.h"
#import "GHPDiffViewTableViewCell.h"
#import "BlocksKit.h"

@implementation GHCommitDiffViewController

@synthesize diffString=_diffString, diffView=_diffView;

#pragma mark - setters and getters

- (void)setDiffString:(NSString *)diffString {
    _diffString = [diffString copy];
    
    self.diffView.diffString = diffString;
}

#pragma mark - Initialization

- (id)initWithDiffString:(NSString *)diffString {
    if ((self = [super init])) {
        self.diffString = diffString;
    }
    return self;
}

#pragma mark - Memory management


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)loadView {
    _scrollView = [[UIScrollView alloc] initWithFrame:[UIScreen mainScreen].bounds ];
    _scrollView.backgroundColor = [UIColor whiteColor];
    _scrollView.scrollsToTop = YES;
    self.view = _scrollView;
    
    CGFloat height = [GHPDiffViewTableViewCell heightWithContent:self.diffString];
    CGRect frame = _scrollView.bounds;
    frame.size.height = height;
    self.diffView = [[GHPDiffView alloc] initWithFrame:frame];
    self.diffView.diffString = self.diffString;
    _scrollView.contentSize = self.diffView.bounds.size;
    [self.view addSubview:self.diffView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSArray *viewControllers = self.navigationController.viewControllers;
    if (viewControllers.count > 0 && [viewControllers objectAtIndex:0] == self) {
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                   handler:^(id sender) {
                                                                                       [self dismissModalViewControllerAnimated:YES];
                                                                                   }];
        self.navigationItem.rightBarButtonItem = doneButton;
    } else {
        UIImage *image = [UIImage imageNamed:@"11-arrows-out.png"];
        UIBarButtonItem *fullScreenButton = [[UIBarButtonItem alloc] initWithImage:image
                                                                             style:UIBarButtonItemStyleBordered
                                                                           handler:^(id sender) {
                                                                               GHCommitDiffViewController *viewController = [[GHCommitDiffViewController alloc] initWithDiffString:_diffString];
                                                                               viewController.title = self.title;
                                                                               
                                                                               UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
                                                                               
                                                                               [self presentModalViewController:navigationController animated:YES];
                                                                           }];
        
        self.navigationItem.rightBarButtonItem = fullScreenButton;
    }
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    _diffView = nil;
    _scrollView = nil;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    CGRect frame = _diffView.frame;
    frame.size.width = CGRectGetWidth(self.view.bounds);
    _diffView.frame = frame;
    
    _scrollView.contentSize = _diffView.bounds.size;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    
    CGRect frame = _diffView.frame;
    frame.size.width = CGRectGetWidth(self.view.bounds);
    _diffView.frame = frame;
    
    _scrollView.contentSize = _diffView.bounds.size;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return toInterfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
}

#pragma mark - Keyed Archiving

- (void)encodeWithCoder:(NSCoder *)encoder {
    [super encodeWithCoder:encoder];
    [encoder encodeObject:_diffString forKey:@"diffString"];
    [encoder encodeObject:_diffView forKey:@"diffView"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super initWithCoder:decoder])) {
        _diffString = [decoder decodeObjectForKey:@"diffString"];
        _diffView = [decoder decodeObjectForKey:@"diffView"];
    }
    return self;
}

@end
