//
//  GHPIssuesViewController.h
//  iGithub
//
//  Created by Oliver Letterer on 04.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GHPDataArrayViewController.h"

@interface GHPIssuesViewController : GHPDataArrayViewController {
@private
    NSString *_repository;
}

@property (nonatomic, copy) NSString *repository;

- (id)initWithRepository:(NSString *)repository;


@end
