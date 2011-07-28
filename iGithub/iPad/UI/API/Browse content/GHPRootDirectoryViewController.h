//
//  GHPRootDirectoryViewController.h
//  iGithub
//
//  Created by Oliver Letterer on 07.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GHPDirectoryViewController.h"

@interface GHPRootDirectoryViewController : GHPDirectoryViewController {
@private
    
}

- (id)initWithRepository:(NSString *)repository branch:(NSString *)branch hash:(NSString *)hash;


@end
