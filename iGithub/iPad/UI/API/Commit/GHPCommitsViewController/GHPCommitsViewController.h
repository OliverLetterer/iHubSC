//
//  GHPCommitsViewController.h
//  iGithub
//
//  Created by Oliver Letterer on 02.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GHPDataArrayViewController.h"



@interface GHPCommitsViewController : GHPDataArrayViewController <NSCoding> {
@protected
    NSString *_repository;
    NSString *_branchHash;
}

@property (nonatomic, copy) NSString *repository;
@property (nonatomic, copy) NSString *branchHash;

- (void)setRepository:(NSString *)repository branchHash:(NSString *)branchHash;

- (id)initWithRepository:(NSString *)repository branchHash:(NSString *)branchHash;
- (id)initWithRepository:(NSString *)repository commits:(NSArray *)commits;

@end
