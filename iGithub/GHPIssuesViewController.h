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
    NSString *_username;
}

@property (nonatomic, copy) NSString *repository;
@property (nonatomic, copy) NSString *username;

- (id)initWithRepository:(NSString *)repository;
- (id)initWithUsername:(NSString *)username;

- (NSString *)descriptionStringForIssue:(GHAPIIssueV3 *)issue;

@end
