//
//  GHPLeftNavigationController.m
//  iGithub
//
//  Created by Oliver Letterer on 30.06.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHPLeftNavigationController.h"
#import "GHPLeftNavigationControllerTableViewCell.h"
#import "GHPEdgedLineView.h"
#import "GHAPIAuthenticationManager.h"
#import "GithubAPI.h"
#import "UIImage+Resize.h"
#import "UIImage+UITabBarStyle.h"
#import "ANAdvancedNavigationController.h"
#import "GHPSearchViewController.h"
#import "GHPOwnersNewsFeedViewController.h"
#import "GHPUsersNewsFeedViewController.h"
#import "GHManageAuthenticatedUsersAlertView.h"
#import "GHPIssuesOfAuthenticatedUserViewController.h"
#import "GHPOrganizationNewsFeedViewController.h"

#import "GHPUserViewController.h"

#define kUITableViewSectionUsername         0
#define kUITableViewSectionNewsFeed         1
#define kUITableViewSectionOrganizations    2
#define kUITableViewSectionBottom           3

#define kUITableViewNumberOfSections        4

@interface GHPLeftNavigationController ()

- (NSURL *)_URLForOwnersNewsFeedViewController;

@end

@implementation GHPLeftNavigationController

@synthesize lineView=_lineView, controllerView=_controllerView;
@synthesize organizations=_organizations;
@synthesize mySelectedIndexPath=_mySelectedIndexPath;

- (id)initWithStyle:(UITableViewStyle)style
{
    if (self = [super initWithStyle:UITableViewStylePlain]) {
        // Custom initialization
        [self pullToReleaseTableViewReloadData];
        self.reloadDataOnApplicationWillEnterForeground = YES;
        self.pullToReleaseEnabled = YES;
    }
    return self;
}

- (void)pullToReleaseTableViewReloadData
{
    [super pullToReleaseTableViewReloadData];
    [self downloadOrganizations];
}

#pragma mark - authentication

- (void)authenticationManagerDidAuthenticateUserCallback:(NSNotification *)notification
{
    [super authenticationManagerDidAuthenticateUserCallback:notification];
    [self downloadOrganizations];
    
    if (self.isViewLoaded) {
        [self.tableView reloadData];
        
        _resetNewsFeedData = YES;
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:kUITableViewSectionNewsFeed];
        [self.tableView selectRowAtIndexPath:indexPath 
                                    animated:NO 
                              scrollPosition:UITableViewScrollPositionNone];
        [self tableView:self.tableView didSelectRowAtIndexPath:indexPath];
    }
}

#pragma mark - instance methods

- (void)downloadOrganizations
{
    self.organizations = nil;
    if (self.isViewLoaded) {
        [self.tableView reloadData];
    }
    [GHAPIOrganizationV3 organizationsOfUser:[GHAPIAuthenticationManager sharedInstance].authenticatedUser.login 
                                        page:1 
                           completionHandler:^(NSMutableArray *array, NSUInteger nextPage, NSError *error) {
                               [self pullToReleaseTableViewDidReloadData];
                               if (error) {
                                   [self handleError:error];
                               } else {
                                   self.organizations = array;
                                   if (self.isViewLoaded) {
                                       [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:kUITableViewSectionOrganizations]
                                                     withRowAnimation:UITableViewRowAnimationFade];
                                   }
                               }
                           }];
}

- (void)gearButtonClicked:(UIButton *)button
{
    GHManageAuthenticatedUsersAlertView *alert = [[GHManageAuthenticatedUsersAlertView alloc] initWithTitle:nil 
                                                                                                    message:nil 
                                                                                                   delegate:nil 
                                                                                          cancelButtonTitle:nil 
                                                                                          otherButtonTitles:nil];
    [alert show];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundView = nil;
    self.tableView.tableFooterView = nil;
    self.tableView.tableHeaderView = nil;
    self.tableView.contentInset = UIEdgeInsetsZero;
    
    CGRect frame = CGRectMake(CGRectGetWidth(self.view.bounds)-2.0f, 0.0f, 2.0f, CGRectGetHeight(self.view.bounds));
    GHPEdgedLineView *lineView = [[GHPEdgedLineView alloc] initWithFrame:frame];
    lineView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin;
    [self.view addSubview:lineView];
    
    self.lineView = lineView;
    
    // wrapper view
    UIView *wrapperView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetHeight(self.tableView.bounds)-44.0f, 300.0f, 44.0f)];
    wrapperView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    wrapperView.backgroundColor = [UIColor clearColor];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *gear = [UIImage imageNamed:@"19-gear.png"];
    [button setImage:gear.unselectedTabBarStyledImage forState:UIControlStateNormal];
    [button setImage:gear.selectedTabBarStyledImage forState:UIControlStateHighlighted];
    [button setImage:gear.selectedTabBarStyledImage forState:UIControlStateSelected];
    [button addTarget:self action:@selector(gearButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    button.frame = CGRectMake(0.0f, 0.0f, CGRectGetHeight(wrapperView.bounds), CGRectGetHeight(wrapperView.bounds));
    [wrapperView addSubview:button];
    
    lineView = [[GHPEdgedLineView alloc] initWithFrame:CGRectZero];
    lineView.transform = CGAffineTransformMakeRotation(M_PI / 2.0f);
    lineView.frame = CGRectMake(0.0f, 0.0f, CGRectGetWidth(wrapperView.bounds), 2.0f);
    lineView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [wrapperView addSubview:lineView];
    
    NSDictionary *newActions = [NSDictionary dictionaryWithObjectsAndKeys:[NSNull null], @"onOrderIn",
                                [NSNull null], @"onOrderOut",
                                [NSNull null], @"sublayers",
                                [NSNull null], @"contents",
                                [NSNull null], @"bounds",
                                nil];
    
    CAGradientLayer *gradientLayer = nil;
    UIView *gradientView = nil;
    
    gradientView = [[UIView alloc] initWithFrame:CGRectMake(0, -22.0f, CGRectGetWidth(wrapperView.bounds), 22.0f)];
	gradientView.backgroundColor = [UIColor clearColor];
	gradientLayer = [CAGradientLayer layer];
	gradientLayer.frame = CGRectMake(0.0f, 0.0f, 480.0f, 22.0f);
	gradientLayer.colors = [NSArray arrayWithObjects:
							(__bridge id)[UIColor colorWithWhite:0.0f alpha:0.0f].CGColor,
							(__bridge id)[UIColor colorWithWhite:0.0f alpha:0.2f].CGColor,
							nil];
    gradientLayer.actions = newActions;
	[gradientView.layer addSublayer:gradientLayer];
    gradientView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [wrapperView addSubview:gradientView];
    self.controllerView = wrapperView;
    
    [self.tableView addSubview:wrapperView];
    
    [self scrollViewDidScroll:self.tableView];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.lineView = nil;
    self.controllerView = nil;
    self.lastSelectedIndexPath = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self scrollViewDidScroll:self.tableView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.tableView reloadData];
    if (self.mySelectedIndexPath) {
        [self.tableView selectRowAtIndexPath:self.mySelectedIndexPath 
                                    animated:NO 
                              scrollPosition:UITableViewScrollPositionNone];
    }
    
    if (self.advancedNavigationController.rightViewControllers.count == 0) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:kUITableViewSectionNewsFeed];
        [self.tableView selectRowAtIndexPath:indexPath 
                                    animated:NO 
                              scrollPosition:UITableViewScrollPositionNone];
        [self tableView:self.tableView didSelectRowAtIndexPath:indexPath];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return kUITableViewNumberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == kUITableViewSectionUsername) {
        return 1;
    } else if (section == kUITableViewSectionNewsFeed) {
        // News Feed + Your Actions
        return 2;
    } else if (section == kUITableViewSectionBottom) {
        // My Profile + My Issues
        return 2;
    } else if (section == kUITableViewSectionOrganizations) {
        // My Profile + Search
        return self.organizations.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == kUITableViewSectionUsername) {
        static NSString *CellIdentifier = @"GHPLeftNavigationControllerTableViewCellUser";
        
        GHPLeftNavigationControllerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[GHPLeftNavigationControllerTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                                                    reuseIdentifier:CellIdentifier];
            cell.textLabel.textColor = [UIColor whiteColor];
        }
        
        cell.textLabel.text = [GHAPIAuthenticationManager sharedInstance].authenticatedUser.login;
        
        [self updateImageView:cell.imageView atIndexPath:indexPath withAvatarURLString:[GHAPIAuthenticationManager sharedInstance].authenticatedUser.avatarURL];
        
        return cell;
    } else {
        static NSString *CellIdentifier = @"GHPLeftNavigationControllerTableViewCell";
        
        GHPLeftNavigationControllerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[GHPLeftNavigationControllerTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                                                    reuseIdentifier:CellIdentifier];
        }
        
        if (indexPath.section == kUITableViewSectionNewsFeed) {
            if (indexPath.row == 0) {
                cell.textLabel.text = NSLocalizedString(@"News Feed", @"");
                [cell setItemImage:[UIImage imageNamed:@"56-feed.png"] ];
            } else if (indexPath.row == 1) {
                cell.textLabel.text = NSLocalizedString(@"My Actions", @"");
                [cell setItemImage:nil ];
            }
        } else if (indexPath.section == kUITableViewSectionBottom) {
            if (indexPath.row == 0) {
                cell.textLabel.text = NSLocalizedString(@"My Profile", @"");
                [cell setItemImage:[UIImage imageNamed:@"145-persondot.png"] ];
            } else if (indexPath.row == 1) {
                cell.textLabel.text = NSLocalizedString(@"My Issues", @"");
                [cell setItemImage:[UIImage imageNamed:@"162-receipt.png"] ];
            }
        } else if (indexPath.section == kUITableViewSectionOrganizations) {
            // My Profile + Search
            GHAPIOrganizationV3 *organization = [self.organizations objectAtIndex:indexPath.row];
            cell.textLabel.text = organization.login;
            [cell setItemImage:nil ];
        }
        
        return cell;
    }
    
    
    
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self scrollViewDidScroll:self.tableView];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIViewController *viewController = nil;
    
    // serialize GHPOwnersNewsFeedViewController if there is one
    NSArray *rightViewControllers = self.advancedNavigationController.rightViewControllers;
    if (rightViewControllers.count > 0) {
        UIViewController *rootViewController = [rightViewControllers objectAtIndex:0];
        
        if ([rootViewController isKindOfClass:GHPOwnersNewsFeedViewController.class]) {
            NSURL *serializationURL = self._URLForOwnersNewsFeedViewController;
            
            [NSKeyedArchiver archiveRootObject:rootViewController toFile:serializationURL.relativePath];
        }
    }
    
    if (indexPath.section == kUITableViewSectionNewsFeed) {
        if (indexPath.row == 0) {
            NSURL *serializationURL = self._URLForOwnersNewsFeedViewController;
            viewController = [NSKeyedUnarchiver unarchiveObjectWithFile:serializationURL.relativePath];
            
            if (_resetNewsFeedData) {
                viewController = nil;
                _resetNewsFeedData = NO;
            }
            
            if (!viewController) {
                // GHPOwnersNewsFeedViewController was not found because it was never used or the version was updated. perform some cleanup
                NSURL *libraryURL = [[NSFileManager defaultManager] URLsForDirectory:NSLibraryDirectory inDomains:NSUserDomainMask].lastObject;
                
                NSArray *libraryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:libraryURL 
                                                                        includingPropertiesForKeys:nil 
                                                                                           options:0
                                                                                             error:NULL];
                for (NSURL *fileURL in libraryContent) {
                    NSString *fileName = fileURL.lastPathComponent;
                    if ([fileName hasPrefix:@"de.olettere.GHPOwnersNewsFeedViewController."] && [fileName hasSuffix:@".plist"]) {
                        [[NSFileManager defaultManager] removeItemAtURL:fileURL error:NULL];
                    }
                }
                
                viewController = [[GHPOwnersNewsFeedViewController alloc] init];
            }
        } else if (indexPath.row == 1) {
            viewController = [[GHPUsersNewsFeedViewController alloc] initWithUsername:[GHAPIAuthenticationManager sharedInstance].authenticatedUser.login ];
        }
    } else if (indexPath.section == kUITableViewSectionBottom) {
        if (indexPath.row == 0) {
            viewController = [[GHPUserViewController alloc] initWithUsername:[GHAPIAuthenticationManager sharedInstance].authenticatedUser.login ];
            [(GHPUserViewController *)viewController setReloadDataIfNewUserGotAuthenticated:YES];
        } else if (indexPath.row == 1) {
            viewController = [[GHPIssuesOfAuthenticatedUserViewController alloc] init];
        }
    } else if (indexPath.section == kUITableViewSectionOrganizations) {
        // My Profile + Search
        GHAPIOrganizationV3 *organization = [self.organizations objectAtIndex:indexPath.row];
        viewController = [[GHPOrganizationNewsFeedViewController alloc] initWithUsername:organization.login ];
    }
    
    if (viewController) {
        self.lastSelectedIndexPath = indexPath;
        [self.advancedNavigationController pushViewController:viewController afterViewController:nil animated:self.advancedNavigationController.rightViewControllers.count > 1];
    } else {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        [tableView selectRowAtIndexPath:self.lastSelectedIndexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == kUITableViewSectionUsername) {
        return 60.0f;
    }
    return 44.0f;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([super respondsToSelector:@selector(scrollViewDidScroll:)]) {
        [super scrollViewDidScroll:scrollView];
    }
    CGRect frame = self.lineView.frame;
    frame.origin.y = scrollView.bounds.origin.y;
    self.lineView.frame = frame;
    
    frame = self.controllerView.frame;
    frame.origin.y = scrollView.bounds.origin.y + CGRectGetHeight(scrollView.bounds) - 44.0f;
    self.controllerView.frame = frame;
}

#pragma mark - Keyed Archiving

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [super encodeWithCoder:encoder];
    [encoder encodeObject:_organizations forKey:@"organizations"];
}

- (id)initWithCoder:(NSCoder *)decoder
{
    if ((self = [super initWithCoder:decoder])) {
        _organizations = [decoder decodeObjectForKey:@"organizations"];
        self.mySelectedIndexPath = self.lastSelectedIndexPath;
        self.lastSelectedIndexPath = nil;
    }
    return self;
}

#pragma mark - private implementation ()

- (NSURL *)_URLForOwnersNewsFeedViewController
{
    NSURL *documentsURL = [[NSFileManager defaultManager] URLsForDirectory:NSLibraryDirectory inDomains:NSUserDomainMask].lastObject;
    
    NSString *bundleVersionKey = (NSString *)kCFBundleVersionKey;
    NSString *bundleVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:bundleVersionKey];
    
    NSString *fileName = [NSString stringWithFormat:@"de.olettere.GHPOwnersNewsFeedViewController.%@.plist", bundleVersion];
    
    return [documentsURL URLByAppendingPathComponent:fileName];
}

@end
