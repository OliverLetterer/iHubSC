//
//  GHViewRootDirectoryViewController.h
//  iGithub
//
//  Created by Oliver Letterer on 18.04.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GHViewDirectoryViewController.h"

@interface GHViewRootDirectoryViewController : GHViewDirectoryViewController {
@private
    
}

- (id)initWithRepository:(NSString *)repository branch:(NSString *)branch hash:(NSString *)hash;

@end
