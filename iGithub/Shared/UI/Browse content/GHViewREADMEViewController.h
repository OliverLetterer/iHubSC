//
//  GHViewREADMEViewController.h
//  iGithub
//
//  Created by Oliver Letterer on 30.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GHViewCloudFileViewController.h"

@interface GHViewREADMEViewController : GHViewCloudFileViewController {
@private
    NSString *_branchHash;
}

@property (nonatomic, copy) NSString *branchHash;

- (id)initWithRepository:(NSString *)repository;

@end
