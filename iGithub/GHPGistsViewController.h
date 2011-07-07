//
//  GHPGistsViewController.h
//  iGithub
//
//  Created by Oliver Letterer on 07.07.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GHTableViewController.h"

@interface GHPGistsViewController : GHTableViewController {
@private
    NSMutableArray *_gists;
}

@property (nonatomic, retain) NSMutableArray *gists;

- (void)cacheGistsHeights;

@end
