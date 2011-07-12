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
#import "GHAuthenticationManager.h"
#import "GithubAPI.h"
#import "GHSettingsHelper.h"
#import "UIImage+Resize.h"
#import "UIImage+GHTabBar.h"
#import "ANAdvancedNavigationController.h"
#import "GHPSearchViewController.h"
#import "GHPOwnersNewsFeedViewController.h"
#import "GHPUsersNewsFeedViewController.h"

#import "GHPUserViewController.h"

#define kUITableViewSectionUsername         0
#define kUITableViewSectionNewsFeed         1
#define kUITableViewSectionOrganizations    2
#define kUITableViewSectionBottom           3

#define kUITableViewNumberOfSections        4

@implementation GHPLeftNavigationController

@synthesize lineView=_lineView, controllerView=_controllerView;
@synthesize lastSelectedIndexPath=_lastSelectedIndexPath;
@synthesize organizations=_organizations;

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        // Custom initialization
        [self downloadOrganizations];
        self.reloadDataOnApplicationWillEnterForeground = YES;
    }
    return self;
}

- (void)pullToReleaseTableViewReloadData {
    [self downloadOrganizations];
}

#pragma mark - authentication

- (void)authenticationManagerDidAuthenticateUserCallback:(NSNotification *)notification {
    [super authenticationManagerDidAuthenticateUserCallback:notification];
    [self downloadOrganizations];
    
    if (self.isViewLoaded) {
        [self.tableView reloadData];
    }
}

#pragma mark - instance methods

- (void)downloadOrganizations {
    self.organizations = nil;
    [GHAPIOrganizationV3 organizationsOfUser:[GHAuthenticationManager sharedInstance].username 
                                        page:1 
                           completionHandler:^(NSMutableArray *array, NSUInteger nextPage, NSError *error) {
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

- (void)gearButtonClicked:(UIButton *)button {
    UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Account", @"") 
                                                     message:[NSString stringWithFormat:NSLocalizedString(@"You are logged in as: %@\nRemaining API calls for today: %d", @""), [GHAuthenticationManager sharedInstance].username, [GHBackgroundQueue sharedInstance].remainingAPICalls ]
                                                    delegate:self 
                                           cancelButtonTitle:NSLocalizedString(@"Cancel", @"") 
                                           otherButtonTitles:NSLocalizedString(@"Logout", @""), nil]
                          autorelease];
    [alert show];
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundView = nil;
    self.tableView.tableFooterView = nil;
    self.tableView.tableHeaderView = nil;
    self.tableView.contentInset = UIEdgeInsetsZero;
    
    CGRect frame = CGRectMake(CGRectGetWidth(self.view.bounds)-2.0f, 0.0f, 2.0f, CGRectGetHeight(self.view.bounds));
    GHPEdgedLineView *lineView = [[[GHPEdgedLineView alloc] initWithFrame:frame] autorelease];
    lineView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin;
    [self.view addSubview:lineView];
    
    self.lineView = lineView;
    
    // wrapper view
    UIView *wrapperView = [[[UIView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetHeight(self.tableView.bounds)-44.0f, 300.0f, 44.0f)] autorelease];
    wrapperView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    wrapperView.backgroundColor = [UIColor clearColor];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *gear = [UIImage imageNamed:@"19-gear.png"];
    [button setImage:[gear tabBarStyledImageWithSize:gear.size style:NO] forState:UIControlStateNormal];
    [button setImage:[gear tabBarStyledImageWithSize:gear.size style:YES] forState:UIControlStateHighlighted];
    [button setImage:[gear tabBarStyledImageWithSize:gear.size style:YES] forState:UIControlStateSelected];
    [button addTarget:self action:@selector(gearButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    button.frame = CGRectMake(0.0f, 0.0f, CGRectGetHeight(wrapperView.bounds), CGRectGetHeight(wrapperView.bounds));
    [wrapperView addSubview:button];
    
    lineView = [[[GHPEdgedLineView alloc] initWithFrame:CGRectZero] autorelease];
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
    
    gradientView = [[[UIView alloc] initWithFrame:CGRectMake(0, -22.0f, CGRectGetWidth(wrapperView.bounds), 22.0f)] autorelease];
	gradientView.backgroundColor = [UIColor clearColor];
	gradientLayer = [CAGradientLayer layer];
	gradientLayer.frame = CGRectMake(0.0f, 0.0f, 480.0f, 22.0f);
	gradientLayer.colors = [NSArray arrayWithObjects:
							(id)[UIColor colorWithWhite:0.0f alpha:0.0f].CGColor,
							(id)[UIColor colorWithWhite:0.0f alpha:0.2f].CGColor,
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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self scrollViewDidScroll:self.tableView];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
	return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return kUITableViewNumberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == kUITableViewSectionUsername) {
        return 1;
    } else if (section == kUITableViewSectionNewsFeed) {
        // News Feed + Your Actions
        return 2;
    } else if (section == kUITableViewSectionBottom) {
        // My Profile + Search
        return 2;
    } else if (section == kUITableViewSectionOrganizations) {
        // My Profile + Search
        return self.organizations.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == kUITableViewSectionUsername) {
        static NSString *CellIdentifier = @"GHPLeftNavigationControllerTableViewCellUser";
        
        GHPLeftNavigationControllerTableViewCell *cell = (GHPLeftNavigationControllerTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[GHPLeftNavigationControllerTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                                                    reuseIdentifier:CellIdentifier] 
                    autorelease];
            cell.textLabel.textColor = [UIColor whiteColor];
        }
        
        cell.textLabel.text = [GHAuthenticationManager sharedInstance].username;
        
        [self updateImageView:cell.imageView atIndexPath:indexPath withAvatarURLString:[GHSettingsHelper avatarURL]];
        
        return cell;
    } else {
        static NSString *CellIdentifier = @"GHPLeftNavigationControllerTableViewCell";
        
        GHPLeftNavigationControllerTableViewCell *cell = (GHPLeftNavigationControllerTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[GHPLeftNavigationControllerTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                                                    reuseIdentifier:CellIdentifier] 
                    autorelease];
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
                cell.textLabel.text = NSLocalizedString(@"Search", @"");
                [cell setItemImage:[UIImage imageNamed:@"Lupe.PNG"] ];
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

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [self scrollViewDidScroll:self.tableView];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIViewController *viewController = nil;
    
    if (indexPath.section == kUITableViewSectionNewsFeed) {
        if (indexPath.row == 0) {
            viewController = [[[GHPOwnersNewsFeedViewController alloc] init] autorelease];
        } else if (indexPath.row == 1) {
            viewController = [[[GHPUsersNewsFeedViewController alloc] initWithUsername:[GHAuthenticationManager sharedInstance].username ] autorelease];
        }
    } else if (indexPath.section == kUITableViewSectionBottom) {
        if (indexPath.row == 0) {
            viewController = [[[GHPUserViewController alloc] initWithUsername:[GHAuthenticationManager sharedInstance].username ] autorelease];
            [(GHPUserViewController *)viewController setReloadDataIfNewUserGotAuthenticated:YES];
        } else if (indexPath.row == 1) {
            viewController = [[[GHPSearchViewController alloc] init] autorelease];
        }
    } else if (indexPath.section == kUITableViewSectionOrganizations) {
        // My Profile + Search
        GHAPIOrganizationV3 *organization = [self.organizations objectAtIndex:indexPath.row];
        viewController = [[[GHPUsersNewsFeedViewController alloc] initWithUsername:organization.login ] autorelease];
    }
    
    if (viewController) {
        self.lastSelectedIndexPath = indexPath;
        [self.advancedNavigationController pushRootViewController:viewController];
    } else {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        [tableView selectRowAtIndexPath:self.lastSelectedIndexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == kUITableViewSectionUsername) {
        return 60.0f;
    }
    return 44.0f;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGRect frame = self.lineView.frame;
    frame.origin.y = scrollView.bounds.origin.y;
    self.lineView.frame = frame;
    
    frame = self.controllerView.frame;
    frame.origin.y = scrollView.bounds.origin.y + CGRectGetHeight(scrollView.bounds) - 44.0f;
    self.controllerView.frame = frame;
}

#pragma mark - memory management

- (void)dealloc {
    [_lineView release];
    [_controllerView release];
    [_lastSelectedIndexPath release];
    [_organizations release];
    
    [super dealloc];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        // Logout clicked
        [self invalidadUserData];
        [self handleError:[NSError errorWithDomain:@"" code:3 userInfo:nil] ];
    }
}

@end
