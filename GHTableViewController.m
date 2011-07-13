//
//  GHTableViewController.m
//  iGithub
//
//  Created by Oliver Letterer on 06.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHTableViewController.h"
#import "GithubAPI.h"
#import "GHNewsFeedItemTableViewCell.h"
#import "GHTableViewController+private.h"
#import "UIColor+GithubUI.h"

#define kUIActivityIndicatorImageViewTag        1236453

@implementation GHTableViewController

@synthesize nextPageForSectionsDictionary=_nextPageForSectionsDictionary, cachedHeightsDictionary=_cachedHeightsDictionary;
@synthesize reloadDataIfNewUserGotAuthenticated=_reloadDataIfNewUserGotAuthenticated, reloadDataOnApplicationWillEnterForeground=_reloadDataOnApplicationWillEnterForeground;
@synthesize isDownloadingEssentialData=_isDownloadingEssentialData, downloadingEssentialDataView=_downloadingEssentialDataView;

#pragma mark - setters and getters

- (void)setIsDownloadingEssentialData:(BOOL)isDownloadingEssentialData {
    if (isDownloadingEssentialData != _isDownloadingEssentialData) {
        _isDownloadingEssentialData = isDownloadingEssentialData;
        
        if (_isDownloadingEssentialData) {
            [self loadAndDisplayDownloadingEssentialDataView];
        } else {
            [self.downloadingEssentialDataView removeFromSuperview];
            self.downloadingEssentialDataView = nil;
        }
    }
}

- (void)setTableView:(UIExpandableTableView *)tableView {
    [super setTableView:tableView];
}

- (UIExpandableTableView *)tableView {
    return (UIExpandableTableView *)[super tableView];
}

- (UITableViewCell *)dummyCell {
    static NSString *CellIdentifier = @"DummyCell";
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    cell.textLabel.text = @"__DUMMY__";
    // Configure the cell...
    
    return cell;
}

#pragma mark - instance methods

static CGFloat wrapperViewHeight = 21.0f;

- (void)loadAndDisplayDownloadingEssentialDataView {
    if (!self.downloadingEssentialDataView && self.isViewLoaded) {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            UIView *wrapperView = [[[UIView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetHeight(self.view.bounds)/2.0f - wrapperViewHeight/2.0f, CGRectGetWidth(self.view.bounds), wrapperViewHeight)] autorelease];
            wrapperView.backgroundColor = self.view.backgroundColor;
            wrapperView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
            
            UILabel *label = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
            label.font = [UIFont systemFontOfSize:16.0f];
            label.shadowColor = [UIColor whiteColor];
            label.shadowOffset = CGSizeMake(0.0f, 1.0f);
            label.textColor = [UIColor darkGrayColor];
            label.backgroundColor = self.view.backgroundColor;
            label.text = NSLocalizedString(@"Loading", @"");
            [label sizeToFit];
            label.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
            label.center = CGPointMake(CGRectGetWidth(wrapperView.bounds)/2.0f, wrapperViewHeight/2.0f);
            [wrapperView addSubview:label];
            
            UIActivityIndicatorView *activityIndicatorView = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray] autorelease];
            [activityIndicatorView startAnimating];
            activityIndicatorView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
            activityIndicatorView.center = CGPointMake(label.frame.origin.x - 10.0f, label.center.y);
            [wrapperView addSubview:activityIndicatorView];
            
            self.downloadingEssentialDataView = wrapperView;
            [self.view addSubview:wrapperView];
        } else {
            [NSException raise:NSInternalInconsistencyException format:@"isDownloadingEssentialData is not supported on Phone right now"];
        }
    }
}

- (UITableViewCell *)dummyCellWithText:(NSString *)text {
    NSString *CellIdentifier = @"DummyCell";
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    cell.textLabel.text = text;
    
    return cell;
}

- (CGFloat)heightForDescription:(NSString *)description {
    CGSize newSize = [description sizeWithFont:[UIFont systemFontOfSize:12.0] 
                             constrainedToSize:CGSizeMake(222.0f, MAXFLOAT)
                                 lineBreakMode:UILineBreakModeWordWrap];
    
    return newSize.height < 21.0f ? 21.0f : newSize.height;
}

- (void)updateImageView:(UIImageView *)imageView 
            inTableView:(UITableView *)tableView 
            atIndexPath:(NSIndexPath *)indexPath 
         withGravatarID:(NSString *)gravatarID {
    UIImage *gravatarImage = [UIImage cachedImageFromGravatarID:gravatarID];
    
    if (gravatarImage) {
        [[imageView viewWithTag:kUIActivityIndicatorImageViewTag] removeFromSuperview];
        imageView.image = gravatarImage;
    } else {
        imageView.image = [UIImage imageNamed:@"DefaultUserImage.png"];
        [[imageView viewWithTag:kUIActivityIndicatorImageViewTag] removeFromSuperview];
        
        UIActivityIndicatorView *activityIndicatorView = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray] autorelease];
        activityIndicatorView.center = CGPointMake(CGRectGetWidth(imageView.bounds)/2.0f, CGRectGetHeight(imageView.bounds)/2.0f);
        activityIndicatorView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
        [activityIndicatorView startAnimating];
        activityIndicatorView.tag = kUIActivityIndicatorImageViewTag;
        [imageView addSubview:activityIndicatorView];
        
        [UIImage imageFromGravatarID:gravatarID 
               withCompletionHandler:^(UIImage *image, NSError *error, BOOL didDownload) {
                   if (indexPath && [tableView containsIndexPath:indexPath]) {
                       [tableView reloadRowAtIndexPath:indexPath withRowAnimation:UITableViewRowAnimationNone];
                   }
               }];
    }
}

- (void)updateImageView:(UIImageView *)imageView 
            atIndexPath:(NSIndexPath *)indexPath 
         withGravatarID:(NSString *)gravatarID {
    
    [self updateImageView:imageView inTableView:self.tableView atIndexPath:indexPath withGravatarID:gravatarID];
}


- (void)updateImageView:(UIImageView *)imageView 
            inTableView:(UITableView *)tableView 
            atIndexPath:(NSIndexPath *)indexPath 
    withAvatarURLString:(NSString *)avatarURLString {
    UIImage *avatarImage = [UIImage cachedImageFromAvatarURLString:avatarURLString];
    
    if (avatarImage) {
        [[imageView viewWithTag:kUIActivityIndicatorImageViewTag] removeFromSuperview];
        imageView.image = avatarImage;
    } else {
        imageView.image = [UIImage imageNamed:@"DefaultUserImage.png"];
        [[imageView viewWithTag:kUIActivityIndicatorImageViewTag] removeFromSuperview];
        
        UIActivityIndicatorView *activityIndicatorView = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray] autorelease];
        activityIndicatorView.center = CGPointMake(CGRectGetWidth(imageView.bounds)/2.0f, CGRectGetHeight(imageView.bounds)/2.0f);
        activityIndicatorView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
        [activityIndicatorView startAnimating];
        activityIndicatorView.tag = kUIActivityIndicatorImageViewTag;
        [imageView addSubview:activityIndicatorView];
        
        [UIImage imageFromAvatarURLString:avatarURLString 
                    withCompletionHandler:^(UIImage *image, NSError *error, BOOL didDownload) {
                        if (indexPath && [tableView containsIndexPath:indexPath]) {
                            [tableView reloadRowAtIndexPath:indexPath withRowAnimation:UITableViewRowAnimationNone];
                        }
                    }];
    }
}

- (void)updateImageView:(UIImageView *)imageView 
            atIndexPath:(NSIndexPath *)indexPath 
    withAvatarURLString:(NSString *)avatarURLString {
    [self updateImageView:imageView inTableView:self.tableView atIndexPath:indexPath withAvatarURLString:avatarURLString];
}

#pragma mark - Target actions

- (void)authenticationManagerDidAuthenticateUserCallback:(NSNotification *)notification {
    if (self.reloadDataIfNewUserGotAuthenticated) {
        [self pullToReleaseTableViewReloadData];
    }
}

- (void)applicationWillEnterForegroundCallback:(NSNotification *)notification {
    _isInBackgroundMode = NO;
    if (self.reloadDataOnApplicationWillEnterForeground) {
        [self pullToReleaseTableViewReloadData];
    }
}

- (void)applicationDidEnterBackgroundCallback:(NSNotification *)notification {
    _isInBackgroundMode = YES;
}

#pragma mark - pagination

- (id)keyForSection:(NSUInteger)section {
    return [NSNumber numberWithUnsignedInteger:section];
}

- (void)setNextPage:(NSUInteger)nextPage forSection:(NSUInteger)section {
    id key = [self keyForSection:section];
    
    [self.nextPageForSectionsDictionary setObject:[NSNumber numberWithUnsignedInteger:nextPage] forKey:key];
}

- (BOOL)needsToDownloadNextDataInSection:(NSUInteger)section {
    NSNumber *object = [self.nextPageForSectionsDictionary objectForKey:[self keyForSection:section] ];
    
    return [object unsignedIntegerValue] > 1;
}

- (NSUInteger)nextPageForSection:(NSUInteger)section {
    return [[self.nextPageForSectionsDictionary objectForKey:[self keyForSection:section] ] unsignedIntegerValue];
}

- (void)downloadDataForPage:(NSUInteger)page inSection:(NSUInteger)section {
    [self.nextPageForSectionsDictionary removeObjectForKey:[self keyForSection:section] ];
}

#pragma mark - Initialization

- (id)initWithStyle:(UITableViewStyle)style {
    if ((self = [super initWithStyle:style])) {
        _myTableViewStyle = style;
        // Custom initialization
        self.cachedHeightsDictionary = [NSMutableDictionary dictionary];
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(authenticationManagerDidAuthenticateUserCallback:) 
                                                     name:GHAuthenticationManagerDidAuthenticateNewUserNotification 
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(applicationWillEnterForegroundCallback:) 
                                                     name:UIApplicationWillEnterForegroundNotification 
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(applicationDidEnterBackgroundCallback:) 
                                                     name:UIApplicationDidEnterBackgroundNotification 
                                                   object:nil];
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            self.reloadDataOnApplicationWillEnterForeground = NO;
            self.pullToReleaseEnabled = NO;
        } else {
            self.reloadDataOnApplicationWillEnterForeground = YES;
        }
        self.nextPageForSectionsDictionary = [NSMutableDictionary dictionary];
    }
    return self;
}

#pragma mark - Memory management

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_cachedHeightsDictionary release];
    _alertProxy.delegate = nil;
    [_alertProxy release];
    [_nextPageForSectionsDictionary release];
    [_downloadingEssentialDataView release];
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)loadView {
    self.tableView = [[[UIExpandableTableView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0f, 480.0f) style:_myTableViewStyle] autorelease];
    self.tableView.maximumRowCountToStillUseAnimationWhileExpanding = 100;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        NSDictionary *newActions = [NSDictionary dictionaryWithObjectsAndKeys:[NSNull null], @"onOrderIn",
                                    [NSNull null], @"onOrderOut",
                                    [NSNull null], @"sublayers",
                                    [NSNull null], @"contents",
                                    [NSNull null], @"bounds",
                                    nil];
        
        CAGradientLayer *gradientLayer = nil;
        UIView *view = nil;
        
        view = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320.0, 22)] autorelease];
        view.backgroundColor = [UIColor clearColor];
        gradientLayer = [CAGradientLayer layer];
        gradientLayer.frame = CGRectMake(0, 0, 480, 22);
        gradientLayer.colors = [NSArray arrayWithObjects:
                                (id)[UIColor colorWithWhite:0.0 alpha:0.0].CGColor,
                                (id)[UIColor colorWithWhite:0.0 alpha:0.3].CGColor,
                                nil];
        gradientLayer.actions = newActions;
        [view.layer addSublayer:gradientLayer];
        self.tableView.tableHeaderView = view;
        
        view = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320.0, 22)] autorelease];
        view.backgroundColor = [UIColor clearColor];
        gradientLayer = [CAGradientLayer layer];
        gradientLayer.frame = CGRectMake(0, 0, 480, 22);
        gradientLayer.colors = [NSArray arrayWithObjects:
                                (id)[UIColor colorWithWhite:0.0 alpha:0.3].CGColor,
                                (id)[UIColor colorWithWhite:0.0 alpha:0.0].CGColor,
                                nil];
        gradientLayer.actions = newActions;
        [view.layer addSublayer:gradientLayer];
        self.tableView.tableFooterView = view;
        
        self.tableView.contentInset = UIEdgeInsetsMake(-22, 0, -22, 0);
        self.defaultEdgeInset = self.tableView.contentInset;
        self.tableView.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"GHDefaultTableViewBackgroundImage.png"]] autorelease];
    }
    
    if (_isDownloadingEssentialData) {
        [self loadAndDisplayDownloadingEssentialDataView];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.tableView.backgroundColor = [UIColor colorWithRed:219.0f/255.0f green:219.0f/255.0f blue:219.0f/255.0f alpha:1.0f];
        self.tableView.backgroundView = nil;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLineEtched;
        self.tableView.separatorColor = [UIColor clearColor];
    } else {
        self.tableView.scrollsToTop = YES;
        self.tableView.rowHeight = 71.0;
        self.tableView.separatorColor = [UIColor colorWithRed:186.0f/255.0f green:186.0f/255.0f blue:186.0f/255.0f alpha:1.0f];
    }
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    _hasGradientBackgrounds = NO;
    [_downloadingEssentialDataView release], _downloadingEssentialDataView = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        if (!_hasGradientBackgrounds) {
            NSDictionary *newActions = [NSDictionary dictionaryWithObjectsAndKeys:[NSNull null], @"onOrderIn",
                                        [NSNull null], @"onOrderOut",
                                        [NSNull null], @"sublayers",
                                        [NSNull null], @"contents",
                                        [NSNull null], @"bounds",
                                        nil];
            
            UIView *view = self.tableView.backgroundView;
            CAGradientLayer *gradientLayer = nil;
            
            gradientLayer = [CAGradientLayer layer];
            gradientLayer.frame = CGRectMake(0.0f, 0.0f, 320.0f, 22.0f);
            gradientLayer.colors = [NSArray arrayWithObjects:
                                    (id)[UIColor colorWithWhite:0.0 alpha:0.3].CGColor,
                                    (id)[UIColor colorWithWhite:0.0 alpha:0.0].CGColor,
                                    nil];
            gradientLayer.actions = newActions;
            [view.layer addSublayer:gradientLayer];
            
            gradientLayer = [CAGradientLayer layer];
            gradientLayer.frame = CGRectMake(0.0f, self.view.bounds.size.height - 22.0f, 320.0f, 22.0f);
            gradientLayer.colors = [NSArray arrayWithObjects:
                                    (id)[UIColor colorWithWhite:0.0 alpha:0.0].CGColor,
                                    (id)[UIColor colorWithWhite:0.0 alpha:0.3].CGColor,
                                    nil];
            gradientLayer.actions = newActions;
            [view.layer addSublayer:gradientLayer];
            _hasGradientBackgrounds = YES;
        }
        self.navigationController.navigationBar.tintColor = [UIColor defaultNavigationBarTintColor];
    }
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
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return YES;
    }
	return interfaceOrientation == UIInterfaceOrientationPortrait;
}

#pragma mark - UIExpandableTableViewDatasource

- (BOOL)tableView:(UIExpandableTableView *)tableView canExpandSection:(NSInteger)section {
    return NO;
}

- (BOOL)tableView:(UIExpandableTableView *)tableView needsToDownloadDataForExpandableSection:(NSInteger)section {
    return NO;
}

- (UITableViewCell<UIExpandingTableViewCell> *)tableView:(UIExpandableTableView *)tableView expandingCellForSection:(NSInteger)section {
    return nil;
}

#pragma mark - UIExpandableTableViewDelegate

- (void)tableView:(UIExpandableTableView *)tableView downloadDataForExpandableSection:(NSInteger)section {
    
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.0f;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self needsToDownloadNextDataInSection:indexPath.section] && indexPath.row != 0 && indexPath.row == [tableView numberOfRowsInSection:indexPath.section] - 1) {
        [self downloadDataForPage:[self nextPageForSection:indexPath.section] inSection:indexPath.section];
    }
}

#pragma mark - super implementation

- (void)handleError:(NSError *)error {
    if (_isInBackgroundMode) {
        return;
    }
    if ([error code] == 3) {
        // authentication problem
        if (![GHAuthenticationManager sharedInstance].username) {
            // no user is logged in, handle the nice error
            [super handleError:error];
        } else {
            UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Unauthorized", @"") 
                                                             message:NSLocalizedString(@"You don't have permission do view this content. Would you like to change your Account?", @"") 
                                                            delegate:nil 
                                                   cancelButtonTitle:NSLocalizedString(@"No", @"") 
                                                   otherButtonTitles:NSLocalizedString(@"Yes", @""), nil]
                                  autorelease];
            
            [alert show];
            
            self.alertProxy = [[[GHTableViewControllerAlertViewProxy alloc] initWithAlertView:alert delegate:self] autorelease];
        }
    } else {
        [super handleError:error];
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [super scrollViewDidScroll:scrollView];
    
    CGRect frame = self.tableView.backgroundView.frame;
    frame.origin = scrollView.contentOffset;
    self.tableView.backgroundView.frame = frame;
}

@end



@implementation GHTableViewController (iPad)

- (GHPCollapsingAndSpinningTableViewCell *)defaultPadCollapsingAndSpinningTableViewCellForSection:(NSUInteger)section {
    NSString *CellIdentifier = @"GHPCollapsingAndSpinningTableViewCell";
    
    GHPCollapsingAndSpinningTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[GHPCollapsingAndSpinningTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    [self setupDefaultTableViewCell:cell forRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]];
    
    return cell;
}

- (void)setupDefaultTableViewCell:(GHPDefaultTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0 && indexPath.row == [self.tableView numberOfRowsInSection:indexPath.section]-1) {
        cell.customStyle = GHPDefaultTableViewCellStyleTopAndBottom;
    } else if (indexPath.row == 0) {
        cell.customStyle = GHPDefaultTableViewCellStyleTop;
    } else if (indexPath.row == [self.tableView numberOfRowsInSection:indexPath.section]-1) {
        cell.customStyle = GHPDefaultTableViewCellStyleBottom;
    } else {
        cell.customStyle = GHPDefaultTableViewCellStyleCenter;
    }
}

- (GHPDefaultTableViewCell *)defaultTableViewCellForRowAtIndexPath:(NSIndexPath *)indexPath withReuseIdentifier:(NSString *)CellIdentifier {
    GHPDefaultTableViewCell *cell = (GHPDefaultTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[GHPDefaultTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    [self setupDefaultTableViewCell:cell forRowAtIndexPath:indexPath];
    
    return cell;
}

@end






@implementation GHTableViewController (GHHeightCaching)

- (void)cacheHeight:(CGFloat)height forRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.cachedHeightsDictionary setObject:[NSNumber numberWithFloat:height] forKey:indexPath];
}

- (CGFloat)cachedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [[self.cachedHeightsDictionary objectForKey:indexPath] floatValue];
}

- (BOOL)isHeightCachedForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self.cachedHeightsDictionary objectForKey:indexPath] != nil;
}

@end

