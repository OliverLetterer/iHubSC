//
//  GHOwnersOrganizationsNewsFeedViewController.m
//  iGithub
//
//  Created by Oliver Letterer on 06.11.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHOwnersOrganizationsNewsFeedViewController.h"
#import "BlocksKit.h"



@implementation GHOwnersOrganizationsNewsFeedViewController

#pragma mark - instance methods

- (void)downloadNewEventsAfterLastKnownEventDateString:(NSString *)lastKnownEventDateString
{
    if (_defaultOrganizationName) {
        _isDownloadingNewsFeedData = YES;
        
        [GHAPIEventV3 eventsForOrganizationNamed:_defaultOrganizationName 
                        sinceLastEventDateString:lastKnownEventDateString 
                               completionHandler:^(NSArray *events, NSError *error) {
                                   if (error) {
                                       [self handleError:error];
                                   } else {
                                       [self appendNewEvents:events];
                                   }
                                   
                                   self.isDownloadingEssentialData = NO;
                                   [self pullToReleaseTableViewDidReloadData];
                                   
                                   _isDownloadingNewsFeedData = NO;
                               }];
    } else {
        NSString *username = [GHAPIAuthenticationManager sharedInstance].authenticatedUser.login;
        
        [GHAPIOrganizationV3 organizationsOfUser:username
                                            page:1
                               completionHandler:^(NSMutableArray *array, NSUInteger nextPage, NSError *error) {
                                   if (error) {
                                       [self handleError:error];
                                       
                                       self.isDownloadingEssentialData = NO;
                                       [self pullToReleaseTableViewDidReloadData];
                                   } else {
                                       if (array.count == 1) {
                                           GHAPIOrganizationV3 *organization = [array objectAtIndex:0];
                                           _defaultOrganizationName = organization.login;
                                           
                                           [self downloadNewEventsAfterLastKnownEventDateString:lastKnownEventDateString];
                                       } else if (array.count > 1) {
                                           // we have more that one organization, ask the user which one to choose
                                           
                                           UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Select an Organization", @"")];
                                           
                                           for (GHAPIOrganizationV3 *organization in array) {
                                               [sheet addButtonWithTitle:organization.login 
                                                                 handler:^{
                                                                     _defaultOrganizationName = organization.login;
                                                                     [self downloadNewEventsAfterLastKnownEventDateString:lastKnownEventDateString];
                                                                 }];
                                           }
                                           
                                           [sheet addButtonWithTitle:NSLocalizedString(@"Cancel", @"")];
                                           sheet.cancelButtonIndex = sheet.numberOfButtons-1;
                                           
                                           sheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
                                           
                                           [self presentActionSheetFromParentViewController:sheet];
                                       } else {
                                           // user is not part of any organization
                                           
                                           UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Organization Error", @"") 
                                                                                           message:NSLocalizedString(@"You are not part of any Organization!", @"") 
                                                                                          delegate:nil 
                                                                                 cancelButtonTitle:NSLocalizedString(@"OK", @"") 
                                                                                 otherButtonTitles:nil];
                                           [alert show];
                                       }
                                   }
                               }];
    }
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.segmentedControl.selectedSegmentIndex = 2;
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)encoder 
{
    [super encodeWithCoder:encoder];
    [encoder encodeObject:_defaultOrganizationName forKey:@"defaultOrganizationName"];
}

- (id)initWithCoder:(NSCoder *)decoder 
{
    if ((self = [super initWithCoder:decoder])) {
        _defaultOrganizationName = [decoder decodeObjectForKey:@"defaultOrganizationName"];
    }
    return self;
}

@end
