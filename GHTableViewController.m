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
#import "GHAuthenticationViewController.h"
#import "GHTableViewController+private.h"

@implementation GHTableViewController

@synthesize cachedHeightsDictionary=_cachedHeightsDictionary;
@synthesize reloadDataIfNewUserGotAuthenticated=_reloadDataIfNewUserGotAuthenticated, reloadDataOnApplicationWillEnterForeground=_reloadDataOnApplicationWillEnterForeground;

#pragma mark - setters and getters

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

- (void)updateImageViewForCell:(GHNewsFeedItemTableViewCell *)cell 
                   atIndexPath:(NSIndexPath *)indexPath 
                withGravatarID:(NSString *)gravatarID {
    
    UIImage *gravatarImage = [UIImage cachedImageFromGravatarID:gravatarID];
    
    if (gravatarImage) {
        cell.imageView.image = gravatarImage;
        [cell.activityIndicatorView stopAnimating];
    } else {
        [cell.activityIndicatorView startAnimating];
        
        [UIImage imageFromGravatarID:gravatarID 
               withCompletionHandler:^(UIImage *image, NSError *error, BOOL didDownload) {
                   if ([self.tableView containsIndexPath:indexPath]) {
                       [self.tableView reloadRowAtIndexPath:indexPath withRowAnimation:UITableViewRowAnimationNone];
                   }
               }];
    }
}

- (void)authenticationViewControllerdidAuthenticateUserCallback:(NSNotification *)notification {
    if (self.reloadDataIfNewUserGotAuthenticated) {
        [self pullToReleaseTableViewReloadData];
    }
}

- (void)applicationWillEnterForegroundCallback:(NSNotification *)notification {
    if (self.reloadDataOnApplicationWillEnterForeground) {
        [self pullToReleaseTableViewReloadData];
    }
}

#pragma mark - Initialization

- (id)initWithStyle:(UITableViewStyle)style {
    if ((self = [super initWithStyle:style])) {
        // Custom initialization
        self.cachedHeightsDictionary = [NSMutableDictionary dictionary];
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(authenticationViewControllerdidAuthenticateUserCallback:) 
                                                     name:GHAuthenticationViewControllerDidAuthenticateUserNotification 
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(applicationWillEnterForegroundCallback:) 
                                                     name:UIApplicationWillEnterForegroundNotification 
                                                   object:nil];
        
        self.reloadDataOnApplicationWillEnterForeground = YES;
    }
    return self;
}

#pragma mark - Memory management

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_cachedHeightsDictionary release];
    _alertProxy.delegate = nil;
    [_alertProxy release];
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)loadView {
    self.tableView = [[[UIExpandableTableView alloc] initWithFrame:CGRectMake(0.0, 0.0, 10.0, 10.0) style:UITableViewStylePlain] autorelease];
    self.tableView.maximumRowCountToStillUseAnimationWhileExpanding = 100;
    
    NSDictionary *newActions = [NSDictionary dictionaryWithObjectsAndKeys:[NSNull null], @"onOrderIn",
                                       [NSNull null], @"onOrderOut",
                                       [NSNull null], @"sublayers",
                                       [NSNull null], @"contents",
                                       [NSNull null], @"bounds",
                                       nil];
    
    CAGradientLayer *gradientLayer = nil;
    UIView *view = nil;
    
    view = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 480, 22)] autorelease];
	view.backgroundColor = [UIColor clearColor];
	gradientLayer = [CAGradientLayer layer];
	gradientLayer.frame = CGRectMake(0, 0, 480, 22);
	gradientLayer.colors = [NSArray arrayWithObjects:
							(id)[UIColor colorWithWhite:0.0/*1.0*/ alpha:0.0].CGColor,
							(id)[UIColor colorWithWhite:0.0 alpha:0.3].CGColor,
							nil];
    gradientLayer.actions = newActions;
	[view.layer addSublayer:gradientLayer];
	self.tableView.tableHeaderView = view;
	
	view = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 480, 22)] autorelease];
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
    self.tableView.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"backgroundimage.png"]] autorelease];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.scrollsToTop = YES;
//    self.tableView.backgroundColor = [UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0];
//    self.tableView.backgroundColor = [UIColor colorWithRed:235.0/255.0 green:235.0/255.0 blue:235.0/255.0 alpha:1.0];
    self.tableView.rowHeight = 71.0;
//    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLineEtched;
    self.tableView.separatorColor = [UIColor colorWithRed:186.0f/255.0f green:186.0f/255.0f blue:186.0f/255.0f alpha:1.0f];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (!self.tableView.backgroundView) {
        NSDictionary *newActions = [NSDictionary dictionaryWithObjectsAndKeys:[NSNull null], @"onOrderIn",
                                    [NSNull null], @"onOrderOut",
                                    [NSNull null], @"sublayers",
                                    [NSNull null], @"contents",
                                    [NSNull null], @"bounds",
                                    nil];
        
        UIView *view = nil;
        CAGradientLayer *gradientLayer = nil;
        
        view = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"GHBackgroundImage.png"] ] autorelease];
        
        gradientLayer = [CAGradientLayer layer];
        gradientLayer.frame = CGRectMake(0.0f, 0.0f, 480.0f, 22.0f);
        gradientLayer.colors = [NSArray arrayWithObjects:
                                (id)[UIColor colorWithWhite:0.0 alpha:0.3].CGColor,
                                (id)[UIColor colorWithWhite:1.0 alpha:0.0].CGColor,
                                nil];
        gradientLayer.actions = newActions;
        view.layer.actions = newActions;
        view.autoresizingMask = UIViewAutoresizingNone;
        [view.layer addSublayer:gradientLayer];
        
        gradientLayer = [CAGradientLayer layer];
        gradientLayer.frame = CGRectMake(0.0f, self.view.bounds.size.height - 22.0f, 480.0f, 22.0f);
        gradientLayer.colors = [NSArray arrayWithObjects:
                                (id)[UIColor colorWithWhite:1.0 alpha:0.0].CGColor,
                                (id)[UIColor colorWithWhite:0.0 alpha:0.3].CGColor,
                                nil];
        gradientLayer.actions = newActions;
        [view.layer addSublayer:gradientLayer];
        
        
        self.tableView.backgroundView = view;
    }
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:22.0/255.0f green:70.0/255.0f blue:110.0/255.0f alpha:1.0];
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

#pragma mark - super implementation

- (void)handleError:(NSError *)error {
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

