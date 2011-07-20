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
#import "GHPDiffViewTableViewCell.h"

@implementation GHCommitDiffViewController

@synthesize diffString=_diffString, diffView=_diffView;

#pragma mark - setters and getters

- (void)setDiffString:(NSString *)diffString {
    [_diffString release];
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

- (void)dealloc {
    [_diffString release];
    [_diffView release];
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)loadView {
    UIScrollView *scrollView = [[[UIScrollView alloc] initWithFrame:[UIScreen mainScreen].bounds ] autorelease];
    scrollView.backgroundColor = [UIColor whiteColor];
    scrollView.scrollsToTop = YES;
    self.view = scrollView;
    
    
    CGFloat height = [GHPDiffViewTableViewCell heightWithContent:self.diffString];
    CGRect frame = scrollView.bounds;
    frame.size.height = height;
    self.diffView = [[[GHPDiffView alloc] initWithFrame:frame] autorelease];
    self.diffView.diffString = self.diffString;
    scrollView.contentSize = self.diffView.bounds.size;
    [self.view addSubview:self.diffView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    self.diffView = nil;
}

#pragma mark Keyed Archiving

- (void)encodeWithCoder:(NSCoder *)encoder {
    [super encodeWithCoder:encoder];
    [encoder encodeObject:_diffString forKey:@"diffString"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super initWithCoder:decoder])) {
        _diffString = [[decoder decodeObjectForKey:@"diffString"] retain];
    }
    return self;
}

@end
