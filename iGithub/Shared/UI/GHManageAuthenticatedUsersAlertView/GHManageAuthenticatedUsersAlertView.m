//
//  GHManageAuthenticatedUsersAlertView.m
//  iGithub
//
//  Created by Oliver Letterer on 28.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHManageAuthenticatedUsersAlertView.h"
#import "GithubAPI.h"
#import "GHAuthenticationAlertView.h"

#define kUIActivityIndicatorImageViewTag        78361

@implementation GHManageAuthenticatedUsersAlertView

#pragma mark - Initialization

- (id)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ... {
    if (self = [super initWithTitle:NSLocalizedString(@"Accounts", @"") message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"") otherButtonTitles:NSLocalizedString(@"Add", @""), nil]) {
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.tableView.bounds), 21.0f)];
        label.backgroundColor = [UIColor clearColor];
        NSString *description = [NSString stringWithFormat:NSLocalizedString(@"Remaining API calls: %d", @""), [GHAPIBackgroundQueueV3 sharedInstance].remainingAPICalls];
        label.textAlignment = UITextAlignmentCenter;
        label.text = description;
        label.font = [UIFont systemFontOfSize:14.0f];
        label.textColor = [UIColor darkGrayColor];
        self.tableView.tableFooterView = label;
    }
    return self;
}

- (void)updateImageView:(UIImageView *)imageView 
            atIndexPath:(NSIndexPath *)indexPath 
    withAvatarURLString:(NSString *)avatarURLString {
    UIImage *avatarImage = [UIImage cachedImageFromAvatarURLString:avatarURLString];
    
    if (avatarImage) {
        [[imageView viewWithTag:kUIActivityIndicatorImageViewTag] removeFromSuperview];
        imageView.image = avatarImage;
    } else {
        imageView.image = [UIImage imageNamed:@"DefaultUserImage.png"];
        [[imageView viewWithTag:kUIActivityIndicatorImageViewTag] removeFromSuperview];
        
        UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        activityIndicatorView.center = CGPointMake(CGRectGetWidth(imageView.bounds)/2.0f, CGRectGetHeight(imageView.bounds)/2.0f);
        activityIndicatorView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
        [activityIndicatorView startAnimating];
        activityIndicatorView.tag = kUIActivityIndicatorImageViewTag;
        [imageView addSubview:activityIndicatorView];
        
        [UIImage imageFromAvatarURLString:avatarURLString 
                    withCompletionHandler:^(UIImage *image, NSError *error, BOOL didDownload) {
                        @try {
                            NSArray *array = [NSArray arrayWithObject:indexPath];
                            [self.tableView reloadRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationNone];
                        }
                        @catch (NSException *exception) {
                            [self.tableView reloadData];
                        }
                    }];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [GHAPIAuthenticationManager sharedInstance].usersArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *CellIdentifier = @"GHTableViewAlertViewTableViewCell";
	GHTableViewAlertViewTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (!cell) {
		cell = [[GHTableViewAlertViewTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
	}
    GHAPIUserV3 *user = [[GHAPIAuthenticationManager sharedInstance].usersArray objectAtIndex:indexPath.row];
    
	cell.textLabel.text = user.login;
    [self updateImageView:cell.imageView atIndexPath:indexPath withAvatarURLString:user.avatarURL];
    
    if ([user isEqualToUser:[GHAPIAuthenticationManager sharedInstance].authenticatedUser]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
	return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return [GHAPIAuthenticationManager sharedInstance].usersArray.count > 1;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        GHAPIUserV3 *user = [[GHAPIAuthenticationManager sharedInstance].usersArray objectAtIndex:indexPath.row];
        [[GHAPIAuthenticationManager sharedInstance] removeAuthenticatedUser:user];
        
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationRight];
        [tableView reloadData];
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    GHAPIUserV3 *user = [[GHAPIAuthenticationManager sharedInstance].usersArray objectAtIndex:indexPath.row];
    [GHAPIAuthenticationManager sharedInstance].authenticatedUser = user;
    
    [self.tableView reloadData];
    [self dismissWithClickedButtonIndex:NSNotFound animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 45.0f;
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView == self) {
        // this is me
        if (buttonIndex == 1) {
            // Add clicked
            GHAuthenticationAlertView *alert = [[GHAuthenticationAlertView alloc] initWithDelegate:nil showCancelButton:YES];
            [alert show];
        }
    }
}

@end
