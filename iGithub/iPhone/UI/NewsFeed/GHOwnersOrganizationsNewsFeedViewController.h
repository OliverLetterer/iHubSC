//
//  GHOwnersOrganizationsNewsFeedViewController.h
//  iGithub
//
//  Created by Oliver Letterer on 06.11.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "GHUsersNewsFeedsViewController.h"



/**
 @class     GHOwnersOrganizationsNewsFeedViewController
 @abstract  <#abstract comment#>
 */
@interface GHOwnersOrganizationsNewsFeedViewController : GHUsersNewsFeedsViewController <NSCoding> {
@private
    NSString *_defaultOrganizationName;
}

@end
