//
//  GHPLabelViewController.h
//  iGithub
//
//  Created by Oliver Letterer on 09.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GHALabelViewController.h"

@interface GHPLabelViewController : GHALabelViewController {
@private
    
}

- (NSString *)contentForIssue:(GHAPIIssueV3 *)issue;

@end
