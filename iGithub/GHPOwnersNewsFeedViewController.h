//
//  GHPOwnersNewsFeedViewController.h
//  iGithub
//
//  Created by Oliver Letterer on 10.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GHPNewsFeedViewController.h"

@interface GHPOwnersNewsFeedViewController : GHPNewsFeedViewController {
@private
    
}

@end


#warning remove
@interface GHPOwnersNewsFeedViewController (GHPOwnersNewsFeedViewControllerSerializaiton)

- (void)serializeNewsFeed:(GHNewsFeed *)newsFeed;
- (GHNewsFeed *)loadSerializedNewsFeed;

@end
