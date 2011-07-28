//
//  GHOwnerNewsFeedViewController+Private.h
//  iGithub
//
//  Created by Oliver Letterer on 23.06.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GHOwnerNewsFeedViewController.h"

@interface GHOwnerNewsFeedViewController (private)

@property (nonatomic, readonly) BOOL isStateSegmentControlLoaded;

- (void)loadStateSegmentControl;
- (void)unloadStateSegmentControlIfPossible;

- (void)detachNewStateString:(NSString *)stateString removeAfterDisplayed:(BOOL)removeFlag;

@end