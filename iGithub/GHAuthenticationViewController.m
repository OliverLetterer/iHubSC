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
    }
    return self;
}

#pragma mark - Memory management

- (void)dealloc {
    [_tableView release];
    [_imageView release];
    [_activityIndicatorView release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.contentInset = UIEdgeInsetsMake(self.imageView.frame.size.height+self.imageView.frame.origin.y + 10.0, 0, 0, 0);
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    CALayer *layer = self.imageView.layer;
    layer.cornerRadius = 2.0;
    layer.masksToBounds = YES;
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload {
    [_tableView release];
    _tableView = nil;
    [_imageView release];
    _imageView = nil;
    [_activityIndicatorView release];
    _activityIndicatorView = nil;
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
    return NSLocalizedString(@"Please provide your github Username and Password here", @"");
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
        
        [GHUser userWithName:cell.textField.text completionHandler:^(GHUser *user, NSError *error) {
            
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
        [GHUser authenticatedUserWithUsername:self.username 
                                     password:self.password 
                            completionHandler:^(GHUser *user, NSError *error) {
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
                                    [GHSettingsHelper setPassword:user.password];
                                    [GHSettingsHelper setGravatarID:user.gravatarID];
                                    [GHAuthenticationManager sharedInstance].username = user.login;
                                    [GHAuthenticationManager sharedInstance].password = user.password;
                                    
                                    [[NSNotificationCenter defaultCenter] postNotificationName:GHAuthenticationViewControllerDidAuthenticateUserNotification 
                                                                                        object:nil];
                                    
                                    [self.delegate authenticationViewController:self didAuthenticateUser:user];
                                }
                            }];
    }
}

@end
