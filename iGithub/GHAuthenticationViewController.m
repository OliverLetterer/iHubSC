//
//  GHAuthenticationViewController.m
//  iGithub
//
//  Created by Oliver Letterer on 29.03.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHAuthenticationViewController.h"
#import "GHSettingsHelper.h"
#import "GithubAPI.h"
#import <QuartzCore/QuartzCore.h>

#define UsernameCellTag 13374
#define PasswordCellTag 13375
#define TokenCellTag 13376

static const CGFloat kUIKeyboardPortraitHeight = 216.0f;
static const CGFloat kUIKeyboardAnimationDuration = 0.3f;

static BOOL _isOneAuthenticationViewControllerActive = NO;

NSString *const GHAuthenticationViewControllerDidAuthenticateUserNotification = @"GHAuthenticationViewControllerDidAuthenticateUserNotification";

@implementation GHAuthenticationViewController

@synthesize delegate=_delegate;
@synthesize tableView=_tableView, imageView=_imageView, activityIndicatorView=_activityIndicatorView;

#pragma mark - setters and getters

- (NSString *)username {
    UITableViewCellWithTextField *cell = (UITableViewCellWithTextField *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    return cell.textField.text;
}

- (NSString *)password {
    UITableViewCellWithTextField *cell = (UITableViewCellWithTextField *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    return cell.textField.text;
}

+ (BOOL)isOneAuthenticationViewControllerActive {
    return _isOneAuthenticationViewControllerActive;
}

#pragma mark - Initialization

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}

- (id)init {
    if ((self = [super init])) {
        self.title = NSLocalizedString(@"Login", @"");
        
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(keyboardWillShowCallback:) 
                                                     name:UIKeyboardWillShowNotification 
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(keyboardWillHideCallback:) 
                                                     name:UIKeyboardWillHideNotification 
                                                   object:nil];
    }
    return self;
}

#pragma mark - Memory management

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_tableView release];
    [_imageView release];
    [_activityIndicatorView release];
    [_borderImageView release];
    [_glossImageView release];
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - NSNotification callbacks

- (void)keyboardWillShowCallback:(NSNotification *)notification {
    CGRect frame = self.view.frame;
    frame.size.height -= kUIKeyboardPortraitHeight;
    
    [UIView animateWithDuration:kUIKeyboardAnimationDuration 
                     animations:^(void) {
                         self.view.frame = frame;
                     } 
                     completion:^(BOOL finished) {
                         [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0] 
                                               atScrollPosition:UITableViewScrollPositionBottom 
                                                       animated:YES];
                     }];
}

- (void)keyboardWillHideCallback:(NSNotification *)notification {
    CGRect frame = self.view.frame;
    frame.size.height += kUIKeyboardPortraitHeight;
    
    [UIView animateWithDuration:kUIKeyboardAnimationDuration 
                     animations:^(void) {
                         self.view.frame = frame;
                     } 
                     completion:^(BOOL finished) {
                         
                     }];
}

#pragma mark - View lifecycle

- (void)loadView {
    [super loadView];
    
    UIEdgeInsets inset = UIEdgeInsetsMake(100.0f, 0.0f, 0.0f, 0.0f);
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    _tableView.contentInset = inset;
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_tableView];
    
    _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _activityIndicatorView.frame = CGRectMake(150.0f, 45.0f - inset.top, 20.0f, 20.0f);
    _activityIndicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    [_tableView addSubview:_activityIndicatorView];
    
    _borderImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"GHGlossBottomBorder.png"] ];
    _borderImageView.frame = CGRectMake(100.0f, -4.0f - inset.top, 118.0f, 119.0f);
    [_tableView addSubview:_borderImageView];
    
    _imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"DefaultUserImage.png"] ];
    _imageView.frame = CGRectMake(125.0f, 20.0f - inset.top, 70.0f, 70.0f);
    [_tableView addSubview:_imageView];
    
    _glossImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"GHGlossTopBorder.png"] ];
    _glossImageView.frame = CGRectMake(100.0f, -4.0f - inset.top, 118.0f, 119.0f);
    [_tableView addSubview:_glossImageView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.alwaysBounceVertical = YES;
    
    CALayer *layer = self.imageView.layer;
    layer.cornerRadius = 2.0;
    layer.masksToBounds = YES;
}

- (void)viewDidUnload {
    [_tableView release];
    _tableView = nil;
    [_imageView release];
    _imageView = nil;
    [_activityIndicatorView release];
    _activityIndicatorView = nil;
    [_borderImageView release], _borderImageView = nil;
    [_glossImageView release], _glossImageView = nil;
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    _isOneAuthenticationViewControllerActive = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    _isOneAuthenticationViewControllerActive = NO;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    return NSLocalizedString(@"Please provide your GitHub Username and Password here. Your Password will be stored in the keychain safely.", @"");
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {
        NSString *CellIdentifier = @"UsernameCell";
        
        UITableViewCellWithTextField *cell = (UITableViewCellWithTextField *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCellWithTextField alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            cell.textField.autocorrectionType = UITextAutocorrectionTypeNo;
            cell.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        }
        
        cell.textLabel.text = NSLocalizedString(@"Username", @"");
        cell.delegate = self;
        cell.tag = UsernameCellTag;
        
        return cell;
    } else if (indexPath.row == 1) {
        NSString *CellIdentifier = @"PasswordCell";
        
        UITableViewCellWithTextField *cell = (UITableViewCellWithTextField *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCellWithTextField alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            cell.textField.secureTextEntry = YES;
        }
        
        cell.textLabel.text = NSLocalizedString(@"Password", @"");
        cell.delegate = self;
        cell.tag = PasswordCellTag;
        
        return cell;
    } else if (indexPath.row == 2) {
        NSString *CellIdentifier = @"TokenCell";
        
        UITableViewCellWithTextField *cell = (UITableViewCellWithTextField *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCellWithTextField alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            cell.textField.autocorrectionType = UITextAutocorrectionTypeNo;
            cell.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        }
        
        cell.textLabel.text = NSLocalizedString(@"Token", @"");
        cell.delegate = self;
        cell.tag = TokenCellTag;
        
        return cell;
    }
    
    return nil;
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }   
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }   
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
}

#pragma mark - UITableViewCellWithTextFieldDelegate

- (void)cellWithTextFieldDidEnterText:(UITableViewCellWithTextField *)cell {
    if (cell.tag == UsernameCellTag) {
        [GHSettingsHelper setUsername:cell.textField.text];
        UITableViewCellWithTextField *nextCell = (UITableViewCellWithTextField *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0] ];
        [nextCell.textField becomeFirstResponder];
        
        [UIView animateWithDuration:0.3 animations:^(void) {
            self.imageView.alpha = 0.0;
            [self.activityIndicatorView startAnimating];
        }];
        
        [GHUserV3 userWithName:cell.textField.text completionHandler:^(GHUserV3 *user, NSError *error) {
            [UIImage imageFromGravatarID:user.gravatarID withCompletionHandler:^(UIImage *image, NSError *error, BOOL didDownload) {
                self.imageView.image = image;
                [UIView animateWithDuration:0.3 animations:^(void) {
                    self.imageView.alpha = 1.0;
                    [self.activityIndicatorView stopAnimating];
                }];
            }];
            
        }];
    } else if (cell.tag == PasswordCellTag) {
        // check auth
        [GHUserV3 authenticatedUserWithUsername:self.username password:self.password 
                              completionHandler:^(GHUserV3 *user, NSError *error) {
                                  if (error) {
                                      UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"") 
                                                                                       message:[error localizedDescription] 
                                                                                      delegate:nil 
                                                                             cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                                                             otherButtonTitles:nil]
                                                            autorelease];
                                      [alert show];
                                  } else {
                                      
                                      [GHSettingsHelper setUsername:user.login];
                                      [GHSettingsHelper setPassword:self.password];
                                      [GHSettingsHelper setGravatarID:user.gravatarID];
                                      [GHAuthenticationManager sharedInstance].username = user.login;
                                      [GHAuthenticationManager sharedInstance].password = self.password;
                                      
                                      [[NSUserDefaults standardUserDefaults] synchronize];
                                      
                                      [[NSNotificationCenter defaultCenter] postNotificationName:GHAuthenticationViewControllerDidAuthenticateUserNotification 
                                                                                          object:nil];
                                      
                                      [self.delegate authenticationViewController:self didAuthenticateUser:user];
                                  }
                              }];
    }
}

@end
