//
//  GHPModalCommitViewController.h
//  iGithub
//
//  Created by Oliver Letterer on 08.11.11.
//  Copyright 2011 Home. All rights reserved.
//



/**
 @class     GHPModalCommitViewController
 @abstract  <#abstract comment#>
 */
@interface GHPModalCommitViewController : UINavigationController {
@private
    
}

- (id)initWithRepository:(NSString *)repository commitID:(NSString *)commitID;

- (void)doneBarButtonItemClicked:(UIBarButtonItem *)sender;

@end
